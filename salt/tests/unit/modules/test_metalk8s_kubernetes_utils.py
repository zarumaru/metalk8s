import os.path
import yaml

from parameterized import param, parameterized

from kubernetes.client.rest import ApiException

from salt.exceptions import CommandExecutionError

from salttesting.mixins import LoaderModuleMockMixin
from salttesting.unit import TestCase
from salttesting.mock import MagicMock, mock_open, patch
from salttesting.helpers import ForceImportErrorOn

import metalk8s_kubernetes_utils

from tests.unit import utils


YAML_TESTS_FILE = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "files", "test_metalk8s_kubernetes_utils.yaml"
)
with open(YAML_TESTS_FILE) as fd:
    YAML_TESTS_CASES = yaml.safe_load(fd)


class Metalk8sKubernetesUtilsTestCase(TestCase, LoaderModuleMockMixin):
    """
    TestCase for `metalk8s_kubernetes_utils` module
    """
    loader_module = metalk8s_kubernetes_utils

    def test_virtual_success(self):
        """
        Tests the return of `__virtual__` function, success
        """
        reload(metalk8s_kubernetes_utils)
        self.assertEqual(
            metalk8s_kubernetes_utils.__virtual__(),
            'metalk8s_kubernetes'
        )

    @parameterized.expand([
        ("kubernetes.client"),
        ("kubernetes.config"),
        (('urllib3.exceptions', 'urllib3')),
    ])
    def test_virtual_fail_import(self, import_error_on, dep_error=None):
        """
        Tests the return of `__virtual__` function, fail import
        """
        with ForceImportErrorOn(import_error_on):
            reload(metalk8s_kubernetes_utils)
            self.assertTupleEqual(
                metalk8s_kubernetes_utils.__virtual__(),
                (False, 'Missing dependencies: {}'.format(
                    dep_error or import_error_on
                ))
            )

    @utils.parameterized_from_cases(YAML_TESTS_CASES["get_kubeconfig"])
    def test_get_kubeconfig(
        self,
        result,
        api_server_pillar=None,
        config_options=None,
        kwargs={},
    ):
        """
        Tests the return of `get_kubeconfig` function
        """
        pillar_dict = {}
        if api_server_pillar:
            pillar_dict = {'metalk8s': {'api_server': api_server_pillar}}

        config_options_dict = {}
        if config_options:
            config_options_dict = config_options

        config_options_mock = MagicMock(side_effect=config_options_dict.get)

        salt_dict = {
            'config.option': config_options_mock,
        }

        with patch.dict(metalk8s_kubernetes_utils.__pillar__, pillar_dict), \
                patch.dict(metalk8s_kubernetes_utils.__salt__, salt_dict):
            self.assertEqual(
                tuple(result),
                metalk8s_kubernetes_utils.get_kubeconfig(**kwargs)
            )

    @parameterized.expand([
        ({"major": "1", "go_version": "go1.13.8"},),
        ('Failed to get version info', True, True),
    ])
    def test_get_version_info(
        self,
        result,
        get_code_raise=False,
        raises=False,
    ):
        """
        Tests the return of `get_version_info` function
        """
        kubeconfig_mock = MagicMock(
            return_value=('my_kubeconfig.conf', 'my_context')
        )
        api_instance_mock = MagicMock()

        get_code_mock = api_instance_mock.return_value.get_code
        if get_code_raise:
            get_code_mock.side_effect = ApiException('Failed to get version info')
        get_code_mock.return_value.to_dict.return_value = result

        with patch(
            "metalk8s_kubernetes_utils.get_kubeconfig", kubeconfig_mock
            ), patch(
                "kubernetes.config.new_client_from_config", MagicMock()
                ), patch("kubernetes.client.VersionApi", api_instance_mock):
            if raises:
                self.assertRaisesRegexp(
                    CommandExecutionError,
                    result,
                    metalk8s_kubernetes_utils.get_version_info
                )
            else:
                self.assertEqual(
                    metalk8s_kubernetes_utils.get_version_info(),
                    result
                )
            get_code_mock.assert_called()

    @parameterized.expand([
        (True,),
        (False, True),
    ])
    def test_ping(
        self,
        result,
        get_version_info_error=False,
    ):
        """
        Tests the return of `ping` function
        """
        version_info_mock = MagicMock()
        if get_version_info_error:
            version_info_mock.side_effect = CommandExecutionError(
                'Failed to get version info'
            )
        with patch(
            "metalk8s_kubernetes_utils.get_version_info", version_info_mock
        ):
            self.assertEqual(
                result,
                metalk8s_kubernetes_utils.ping(),
            )

    @utils.parameterized_from_cases(
        YAML_TESTS_CASES["read_and_render_yaml_file"]
    )
    def test_read_and_render_yaml_file(
        self,
        source,
        result,
        template=None,
        opts=True,
        raises=False,
        **kwargs
    ):
        """
        Tests the return of `read_and_render_yaml_file` function
        """
        cache_file_mock = MagicMock()
        open_file_mock = mock_open(read_data=source)
        cache_file_mock.return_value = source

        opts_dict = {}
        if opts:
            opts_dict = {
                "cachedir": "/path/to/cache/dir",
                "extension_modules": "/path/to/dummy/extension/module",
                "file_client": "local",
                "file_ignore_glob": None,
                "fileserver_backend": None
            }
        patch_dict = {
            'cp.cache_file': cache_file_mock
        }
        with patch.dict(metalk8s_kubernetes_utils.__opts__, opts_dict), \
                patch.dict(metalk8s_kubernetes_utils.__salt__, patch_dict), \
                patch("salt.utils.files.fopen", open_file_mock):
            if raises:
                self.assertRaisesRegexp(
                    CommandExecutionError,
                    result,
                    metalk8s_kubernetes_utils.read_and_render_yaml_file,
                    source="my-source-file",
                    template=template,
                    **kwargs
                )
            else:
                self.assertEqual(
                    result,
                    metalk8s_kubernetes_utils.read_and_render_yaml_file(
                        source="my-source-file",
                        template=template,
                        **kwargs
                    )
                )
