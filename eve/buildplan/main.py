"""Generate the Eve YAML description of build plan for MetalK8s."""
import sys

from buildplan import core
from buildplan import dsl
from buildplan import yamlprint


def build_project():
    project = core.Project()
    project.add(pre_merge())
    return project


# Stages {{{
@dsl.WithStatus(is_root=True)
def pre_merge():
    return core.Stage(
        name="pre-merge",
        worker=core.LocalWorker(),
        branches=[
            "user/*",
            "feature/*",
            "improvement/*",
            "bugfix/*",
            "w/*",
            "q/*",
            "hotfix/*",
            "dependabot/*",
            "documentation/*",
            "release/*",
        ],
        steps=[
            core.TriggerStages(
                "Trigger build, docs, and lint stages",
                stages=[build(), docs(), lint()],
            ),
            set_version_property(),
            core.TriggerStages(
                "Trigger single-node and multiple-nodes steps with built ISO",
                stages=[single_node(), multiple_nodes()],
            ),
        ],
    )


@dsl.WithStatus()
@dsl.WithArtifacts(urls=["metalk8s.iso", "SHA256SUM", "product.txt"])
@dsl.WithSetup([dsl.SetupStep.DOCKER, dsl.SetupStep.GIT, dsl.SetupStep.CACHE])
def build():
    return core.Stage(
        name="build",
        worker=core.KubePodWorker(
            path="eve/workers/pod-builder/pod.yaml",
            images=[
                core.KubePodWorker.Image(
                    name="docker-builder", context="eve/workers/pod-builder"
                )
            ],
        ),
        steps=[
            build_all(),
            *dsl.copy_artifacts(
                [
                    "build.log",
                    "_build/metalk8s.iso",
                    "_build/SHA256SUM",
                    "_build/root/product.txt",
                ]
            ),
        ],
    )


@dsl.WithStatus()
@dsl.WithArtifacts(
    urls=[
        "docs/html/index.html",
        "docs/latex/MetalK8s.pdf",
        "docs/CHANGELOG.md",
    ]
)
@dsl.WithSetup([dsl.SetupStep.GIT, dsl.SetupStep.CACHE])
def docs():
    return core.Stage(
        name="docs",
        worker=core.KubePodWorker(
            path="eve/workers/pod-docs-builder/pod.yaml",
            images=[
                core.KubePodWorker.Image(
                    name="doc-builder",
                    context=".",
                    dockerfile="docs/Dockerfile",
                )
            ],
        ),
        steps=[
            build_docs(),
            *dsl.copy_artifacts(
                ["docs/_build/*", "CHANGELOG.md"], destination="docs",
            ),
        ],
    )


@dsl.WithStatus()
@dsl.WithSetup([dsl.SetupStep.GIT, dsl.SetupStep.CACHE])
def lint():
    return core.Stage(
        name="lint",
        worker=core.KubePodWorker(
            path="eve/workers/pod-linter/pod.yaml",
            images=[
                core.KubePodWorker.Image(
                    name="docker-linter", context="eve/workers/pod-linter"
                )
            ],
        ),
        steps=[lint_all()],
    )


@dsl.WithStatus()
def single_node():
    return core.Stage(
        name="single-node",
        worker=core.OpenStackWorker(
            path="eve/workers/openstack-single-node",
            flavor=core.OpenStackWorker.Flavor.LARGE,
            image=core.OpenStackWorker.Image.CENTOS7,
        ),
        steps=[],
    )


@dsl.WithStatus()
def multiple_nodes():
    return core.Stage(
        name="multiple-nodes",
        worker=core.OpenStackWorker(
            path="eve/workers/openstack-multiple-nodes",
            flavor=core.OpenStackWorker.Flavor.MEDIUM,
            image=core.OpenStackWorker.Image.CENTOS7,
        ),
        steps=[],
    )


# }}}
# Steps {{{
def set_version_property():
    return core.SetPropertyFromCommand(
        "Set version as property from built artifacts",
        property_name="metalk8s_version",
        command=(
            "bash -c '"
            '. <(curl -s "%(prop:artifacts_private_url)s")'
            " && echo $VERSION'"
        ),
    )


def build_all():
    return core.ShellCommand(
        "Build everything",
        command="./doit.sh -n 4",
        env={"PYTHON_SYS": "python3.6"},
        use_pty=True,
        halt_on_failure=True,
    )


def build_docs():
    return core.ShellCommand(
        "Build documentation",
        command="tox --workdir /tmp/tox -e docs -- html latexpdf",
        env={"READTHEDOCS": "True"},
        halt_on_failure=True,
    )


def lint_all():
    return core.ShellCommand(
        "Run all linting targets",
        command="./doit.sh lint",
        use_pty=True,
        halt_on_failure=False,
    )


# }}}

if __name__ == "__main__":
    build_plan = build_project().dump()
    yamlprint.dump(build_plan, stream=sys.stdout)
