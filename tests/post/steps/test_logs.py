import time

from pytest_bdd import scenario, then

# Scenarios
@scenario('../features/log_accessible.feature',
          'check logs from all containers')
def test_logs(host):
    pass


# Some sidecar containers don't have logs
SKIP_CONTAINERS = frozenset((
    'config-reloader',
    'kube-rbac-proxy',
    'kube-rbac-proxy-main',
    'kube-rbac-proxy-self',
    'rules-configmap-reloader',
    'nginx-ingress-default-backend',
))

@then("all Pod logs should be non-empty")
def check_logs(k8s_client):
    all_pods = k8s_client.list_pod_for_all_namespaces()

    for pod in all_pods.items:
        pod = _wait_for_pod(k8s_client, pod)
        pod_name = pod.metadata.name
        namespace = pod.metadata.namespace

        for container in pod.spec.containers:
            if container.name in SKIP_CONTAINERS:
                continue

            logs = k8s_client.read_namespaced_pod_log(
                pod_name,
                namespace,
                container=container.name
            )

            assert logs.strip(), (
                "Couldn't find logs for container '{}' in Pod '{}' (status {})"
            ).format(container.name, pod_name, pod.status.phase)


def _wait_for_pod(client, pod, max_retries=10):
    retries = 0

    while pod.status.phase != 'Running' and retries <= max_retries:
        time.sleep(2)
        pod = client.read_namespaced_pod(
            name=pod.metadata.name,
            namespace=pod.metadata.namespace,
        )
        retries += 1

    return pod
