import json
import re

import requests
import requests.exceptions

import pytest
from pytest_bdd import scenario, given, then, when, parsers

import kubernetes.client
from kubernetes.client.rest import ApiException

from tests import kube_utils
from tests import utils


# Constants {{{

INGRESS_PORT = 8443

# }}}


# Scenarios {{{

@scenario('../features/authentication.feature', 'List Pods')
def test_list_pods(host):
    pass


@scenario('../features/authentication.feature', 'Expected Pods')
def test_expected_pods(host):
    pass


@scenario('../features/authentication.feature', 'Reach the OpenID Config')
def test_reach_openid_config(host):
    pass


@scenario('../features/authentication.feature', 'Access HTTPS service')
def test_access_https_service(host):
    pass


@scenario('../features/authentication.feature',
          'Login to Dex using incorrect email')
def test_failed_login(host):
    pass


@scenario('../features/authentication.feature',
          'Login to Dex using correct email and password')
def test_login(host):
    pass


@pytest.fixture(scope='function')
def context():
    return {}

# }}}

# Given {{{

# }}}


# When {{{


@when(parsers.parse(
    "we perform a request on '{path}' with port '{port}' on control-plane IP"))
def perform_request(host, context, path, port):
    ip = _get_control_plane_ip(host)
    try:
        context['response'] = requests.get(
            'https://{ip}:{port}{path}'.format(
                ip=ip, port=port, path=path
            ),
            verify=False,
        )
    except requests.exceptions.ConnectionError as exc:
        context['exception'] = exc


@when(parsers.parse(
    "we login to Dex as '{username}' using password '{password}'"))
def dex_login(host, username, password, context):
    ip = _get_control_plane_ip(host)
    context['login_response'] = _dex_auth_request(
        ip, username, password
    )


# }}}


# Then {{{


@then("we can reach the OIDC openID configuration")
def reach_openid_config(host):
    ip = _get_control_plane_ip(host)
    try:
        response = requests.get(
            'https://{ip}:8443/oidc/.well-known/openid-configuration'.format(
                ip=ip
            ),
            verify=False,
        )
    except requests.exceptions.ConnectionError as exc:
        raise ConnectionError(exc)

    assert response.status_code == 200
    response_body = response.json()
    # check for the existence of  keys[issuer, authorization_endpoint]
    assert 'issuer' and 'authorization_endpoint' in response_body


@then(parsers.parse(
    "the server returns '{status_code}' with message '{status_message}'"))
def server_returns(host, context, status_code, status_message):
    response = context.get('response')
    assert response is not None
    assert response.status_code == int(status_code)
    assert response.text.rstrip('\n') == status_message


@then(parsers.parse("authentication fails with login error"))
def failed_login(host, context):
    auth_response = context.get('login_response')
    assert auth_response.text is not None
    assert auth_response.status_code == 200
    #'Invalid Email Address and password' is found in auth_response.text
    assert 'Invalid Email Address and password' in auth_response.text
    assert auth_response.headers.get('location') is None


@then(parsers.parse("the server returns '{status_code}' with an ID token"))
def successful_login(host, context, status_code):
    auth_response = context.get('login_response')
    if auth_response.text is None:
        assert False
    assert auth_response.status_code == int(status_code)
    assert auth_response.headers.get('location') is not None


#  }}}


# Helper {{{


def _get_control_plane_ip(host):
    with host.sudo():
        output = host.check_output(' '.join([
            'salt-call', '--local', '--out=json',
            'grains.get', 'metalk8s:control_plane_ip',
        ]))
        ip = json.loads(output)['local']
    return ip


def _dex_auth_request(control_plane_ip, username, password):
    try:
        response = requests.post(
            'https://{}:{}/oidc/auth?'.format(control_plane_ip, INGRESS_PORT),
            data={
                'response_type': 'id_token',
                'client_id': 'metalk8s-cli',
                'scope': 'openid audience:server:client_id:oidc-auth-client',
                'redirect_uri': 'http://localhost',
                'nonce': 'nonce'
            },
            verify=False,
        )
    except requests.exceptions.ConnectionError as exc:
        raise ConnectionError(exc)

    auth_request = response.text  # response is an html form
    # Obtain the request id using regex search from the return html form
    # form action looks like:
    # <a href="/oidc/auth/local?req=ovc5qdll5zznlubewjok266rl" target="_self">
    try:
        req = re.search('req=(.+?)"', auth_request).group(0)
    except AttributeError as exc:
        raise AttributeError(exc)

    req_stripped = req.rstrip('"')
    try:
        result = requests.post(
            "https://{}:{}/oidc/auth/local?{}".format(
                control_plane_ip, INGRESS_PORT, req_stripped
            ),
            data={
                'login': username,
                'password': password
            },
            verify=False, allow_redirects=False,
        )
    except requests.exceptions.ConnectionError as exc:
        raise ConnectionError(exc)
    return result


# }}}
