# coding: utf-8


"""Module gathering custom tasks producing generic and reusable targets."""


from buildchain.targets.base import Target, AtomicTarget, CompositeTarget
from buildchain.targets.checksum import Sha256Sum
from buildchain.targets.directory import Mkdir
from buildchain.targets.file_tree import FileTree
from buildchain.targets.local_image import LocalImage
from buildchain.targets.package import Package
from buildchain.targets.remote_image import RemoteImage
from buildchain.targets.repository import Repository
from buildchain.targets.serialize import SerializedData
from buildchain.targets.template import TemplateFile

# For mypy, see `--no-implicit-reexport` documentation.
__all__ = [
    'Target', 'AtomicTarget', 'CompositeTarget',
    'Sha256Sum',
    'Mkdir',
    'FileTree',
    'LocalImage',
    'Package',
    'RemoteImage',
    'Repository',
    'SerializedData',
    'TemplateFile',
]
