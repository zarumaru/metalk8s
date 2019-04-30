# -*- coding: utf-8 -*-
from pytest_bdd import given, parsers

from tests import kube_utils


# Pytest-bdd steps

# Given
@given(parsers.parse("pods with label '{label}' are '{state}'"))
def check_pod_state(host, k8s_client, label, state):
    pods = kube_utils.get_pods(
        k8s_client, label, namespace="kube-system", state="Running",
    )

    assert len(pods) > 0, "No {} pod with label '{}' found".format(
        state.lower(), label
    )
