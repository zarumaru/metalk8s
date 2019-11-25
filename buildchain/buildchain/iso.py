# coding: utf-8


"""Tasks for the ISO generation.

This module handles the creation of the final ISO, which involves:
- creating the ISO's root
- populating the ISO's tree
- creating the ISO
- computing the ISO's checksum

Overview:

                                ┌─────────────┐
                        ┌──────>│   images    │────────┐
                        │       └─────────────┘        │
                        │       ┌─────────────┐        │
                ┌────────┐ ╱───>│  packaging  │────╲   v
┌───────┐       │        │╱     └─────────────┘    ┌─────────┐    ┌──────────┐
│ mkdir │──────>│populate│                         │ mkisofs │───>│ checksum │
└───────┘       │        │╲     ┌─────────────┐    └─────────┘    └──────────┘
                └────────┘ ╲───>│  salt_tree  │────╱   ^
                        │       └─────────────┘        │
                        │       ┌─────────────┐        │
                        └──────>│ product.txt │────────┘
                                └─────────────┘
"""


import datetime as dt
import socket
import subprocess
from pathlib import Path
from typing import List, Sequence, Union

import doit  # type: ignore

from buildchain import config
from buildchain import constants
from buildchain import coreutils
from buildchain import targets as helper
from buildchain import types
from buildchain import utils
from buildchain import versions


ISO_FILE : Path = config.BUILD_ROOT/'{}.iso'.format(config.PROJECT_NAME.lower())


def task_iso() -> types.TaskDict:
    """Build the MetalK8s image."""
    return {
        'actions': None,
        'task_dep': [
            '_iso_mkdir_root',
            'populate_iso',
            '_iso_build',
            '_iso_digest',
        ],
    }


def task__iso_mkdir_root() -> types.TaskDict:
    """Create the ISO root directory."""
    return helper.Mkdir(
        directory=constants.ISO_ROOT, task_dep=['_build_root']
    ).task


def task_populate_iso() -> types.TaskDict:
    """Populate the ISO_ROOT with required files."""
    return {
        'basename': 'populate_iso',
        'actions': None,
        'doc': 'Populate {} with required files.'.format(
            utils.build_relpath(constants.ISO_ROOT)
        ),
        # Aggregate here the tasks that put files into ISO_ROOT.
        'task_dep': [
            '_iso_mkdir_root',
            '_iso_render_downgrade',
            '_iso_render_upgrade',
            '_iso_render_bootstrap',
            '_iso_add_node_manifest',
            '_iso_generate_product_txt',
            '_iso_add_utilities_scripts',
            'images',
            'salt_tree',
            'packaging',
        ],
    }

def task__iso_mkdir_examples() -> types.TaskDict:
    """Create ISO_ROOT/examples"""
    return helper.Mkdir(
        directory=constants.ISO_ROOT/"examples", task_dep=['_iso_mkdir_root']
    ).task


def task__iso_add_node_manifest() -> types.TaskDict:
    """Copy the node announcement manifest to examples."""
    # generic node manifest
    src_generic = constants.ROOT/'examples'/'new-node.yaml'
    dest_generic = constants.ISO_ROOT/'examples'/'new-node.yaml'
    new_node_generic = [src_generic, dest_generic]
    # vagrant node manifest
    src_vagrant = constants.ROOT/'examples'/'new-node_vagrant.yaml'
    dest_vagrant = constants.ISO_ROOT/'examples'/'new-node_vagrant.yaml'
    new_node_vagrant = [src_vagrant, dest_vagrant]
    return {
         'title': lambda task: utils.title_with_target1('COPY', task),
         'actions': [
             (coreutils.cp_file, new_node_generic),
             (coreutils.cp_file, new_node_vagrant)
         ],
         'targets': [dest_generic, dest_vagrant],
         'task_dep': ['_iso_mkdir_examples'],
         'file_dep': [src_generic, src_vagrant],
         'clean': True,
     }


def task__iso_add_utilities_scripts() -> types.TaskDict:
    """Copy the ISO manager script to scripts."""
    iso_manager_src = constants.ROOT/'scripts'/'iso-manager.sh'
    iso_manager_dest = constants.ISO_ROOT/'iso-manager.sh'
    iso_manager = [iso_manager_src, iso_manager_dest]

    return {
            'title': lambda task: utils.title_with_target1('COPY', task),
            'actions': [
                    (coreutils.cp_file, iso_manager)
                ],
            'targets': [iso_manager_dest],
            'task_dep': ['_iso_mkdir_root'],
            'file_dep': [iso_manager_src],
            'clean': True,
            }


def task__iso_render_downgrade() -> types.TaskDict:
    """Generate the downgrade script."""
    return helper.TemplateFile(
        source=constants.ROOT/'scripts'/'downgrade.sh.in',
        destination=constants.ISO_ROOT/'downgrade.sh',
        context={'VERSION': versions.VERSION},
        file_dep=[versions.VERSION_FILE],
        task_dep=['_iso_mkdir_root'],
    ).task


def task__iso_render_upgrade() -> types.TaskDict:
    """Generate the upgrade script."""
    return helper.TemplateFile(
        source=constants.ROOT/'scripts'/'upgrade.sh.in',
        destination=constants.ISO_ROOT/'upgrade.sh',
        context={'VERSION': versions.VERSION},
        file_dep=[versions.VERSION_FILE],
        task_dep=['_iso_mkdir_root'],
    ).task


def task__iso_render_bootstrap() -> types.TaskDict:
    """Generate the bootstrap script."""
    return helper.TemplateFile(
        source=constants.ROOT/'scripts'/'bootstrap.sh.in',
        destination=constants.ISO_ROOT/'bootstrap.sh',
        context={'VERSION': versions.VERSION},
        file_dep=[versions.VERSION_FILE],
        task_dep=['_iso_mkdir_root'],
    ).task


def task__iso_generate_product_txt() -> types.TaskDict:
    """Generate the product.txt file."""
    def action(targets: Sequence[str]) -> None:
        datefmt = "%Y-%m-%dT%H:%M:%SZ"
        dev_release = '1' if versions.VERSION_SUFFIX == '-dev' else '0'
        info = (
            ('NAME', config.PROJECT_NAME),
            ('VERSION', versions.VERSION),
            ('SHORT_VERSION', versions.SHORT_VERSION),
            ('GIT', constants.GIT_REF or ''),
            ('DEVELOPMENT_RELEASE', dev_release),
            ('BUILD_TIMESTAMP', dt.datetime.utcnow().strftime(datefmt)),
            ('BUILD_HOST', socket.gethostname()),
        )
        with open(targets[0], 'w', encoding='utf-8') as fp:
            data = '\n'.join('{}={}'.format(key, value) for key, value in info)
            fp.write(data)
            fp.write('\n')

    return {
        'title': lambda task: utils.title_with_target1('GENERATE', task),
        'actions': [action],
        'targets': [constants.ISO_ROOT/'product.txt'],
        'file_dep': [versions.VERSION_FILE],
        'task_dep': ['_iso_mkdir_root'],
        'uptodate': [False],  # False because we include the build timestamp.
        'clean': True,
    }


@doit.create_after(executed='populate_iso')  # type: ignore
def task__iso_build() -> types.TaskDict:
    """Create the ISO from the files in ISO_ROOT."""
    def unlink_if_exist(filepath: Path) -> None:
        """Delete a file if it exists."""
        try:
            filepath.unlink()
        except FileNotFoundError:
            pass

    def mkisofs() -> None:
        """Create an ISO file (delete on error)."""
        cmd : List[Union[str, Path]] = [
            config.ExtCommand.MKISOFS.value, '-output',  ISO_FILE,
            '-quiet',
            '-rock',
            '-joliet',
            '-joliet-long',
            '-full-iso9660-filenames',
            '-volid', '{} {}'.format(config.PROJECT_NAME, versions.VERSION),
            '--iso-level', '3',
            '-gid', '0',
            '-uid', '0',
            '-input-charset', 'utf-8',
            '-output-charset', 'utf-8',
            constants.ISO_ROOT
        ]
        try:
            subprocess.run(cmd, check=True)
        except:
            unlink_if_exist(ISO_FILE)
            raise

    doc = 'Create the ISO from the files in {}.'.format(
        utils.build_relpath(constants.ISO_ROOT)
    )
    # Every file used for the ISO is a dependency.
    depends = list(coreutils.ls_files_rec(constants.ISO_ROOT))
    depends.append(versions.VERSION_FILE)
    return {
        'title': lambda task: utils.title_with_target1('MKISOFS', task),
        'doc': doc,
        'actions': [mkisofs],
        'targets': [ISO_FILE],
        'file_dep': depends,
        'task_dep': ['check_for:mkisofs', '_build_root', '_iso_mkdir_root'],
        'clean': True,
    }


def task__iso_digest() -> types.TaskDict:
    """Compute the SHA256 digest of the ISO."""
    return helper.Sha256Sum(
        input_files=[ISO_FILE],
        output_file=config.BUILD_ROOT/'SHA256SUM',
        task_dep=['_iso_build']
    ).task


__all__ = utils.export_only_tasks(__name__)
