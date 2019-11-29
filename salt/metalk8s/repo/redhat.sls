{%- from "metalk8s/map.jinja" import metalk8s with context %}
{%- from "metalk8s/map.jinja" import repo with context %}

{%- set repo_host = pillar.metalk8s.endpoints['repositories'].ip %}
{%- set repo_port = pillar.metalk8s.endpoints['repositories'].ports.http %}

Set metalk8s_osmajorrelease in yum vars:
  file.managed:
    - name: /etc/yum/vars/metalk8s_osmajorrelease
    - contents: {{ grains['osmajorrelease'] }}

Install yum-plugin-versionlock:
  pkg.installed:
    - name: yum-plugin-versionlock
    - require:
      - test: Repositories configured

{%- for repo_name, repo_config in repo.repositories.items() %}
  {%- if repo.local_mode %}
    {%- set repo_base_url = "file://" ~
                            salt.metalk8s.get_archives()[saltenv].path ~ "/" ~
                            repo.relative_path ~ "/" ~
                            grains['os_family'].lower() %}
  {%- else %}
    {%- set repo_base_url = "http://" ~ repo_host ~ ':' ~ repo_port ~
                            "/" ~ saltenv ~ "/" ~
                            grains['os_family'].lower() %}
  {%- endif %}
  {%- set repo_url = repo_base_url ~ "/" ~ repo_name ~
                     "-el$metalk8s_osmajorrelease" %}
  {%- set gpg_keys = [] %}
  {%- for gpgkey in repo_config.gpgkeys %}
    {%- do gpg_keys.append(repo_url ~ "/" ~ gpgkey) %}
  {%- endfor %}
Configure {{ repo_name }} repository:
  pkgrepo.managed:
    - name: {{ repo_name }}
    - humanname: {{ repo_config.humanname }}
    - baseurl: {{ repo_url }}
    - gpgcheck: {{ repo_config.gpgcheck }}
  {%- if gpg_keys %}
    - gpgkey: "{{ gpg_keys | join (' ') }}"
  {%- endif %}
    - repo_gpg_check: {{ repo_config.repo_gpg_check }}
    - enabled: {{ repo_config.enabled }}
    - proxy: _none_
    - refresh: false
    - onchanges_in:
      - cmd: Refresh yum cache
    - require:
      - file: Set metalk8s_osmajorrelease in yum vars
    - require_in:
      - test: Repositories configured
    - watch_in:
      - module: Check packages availability
{%- endfor %}

# Refresh cache manually as we use the same repo name for all versions
Refresh yum cache:
  # Refresh_db not enough as it's only expire-cache
  cmd.run:
    - name: yum clean all
  module.run:
    - pkg.refresh_db: []
    - onchanges:
      - cmd: Refresh yum cache

Check packages availability:
  module.wait:
    - metalk8s_package_manager.check_pkg_availability:
      - pkgs_info: {{ repo.packages | tojson }}
    - require_in:
      - test: Repositories configured

Repositories configured:
  test.succeed_without_changes: []
