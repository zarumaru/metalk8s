{%- from "metalk8s/macro.sls" import pkg_installed with context %}
{%- from "metalk8s/map.jinja" import repo with context %}

include:
  - metalk8s.repo

Install container-selinux:
  {{ pkg_installed('container-selinux') }}
{%- if repo.online_mode %}
    - sources:
      - container-selinux: ftp://ftp.scientificlinux.org/linux/scientific/7x/external_products/extras/x86_64/container-selinux-2.77-1.el7_6.noarch.rpm
{%- endif %}
    - require:
      - test: Repositories configured

Install runc:
  {{ pkg_installed('runc') }}
    - require:
      - test: Repositories configured
      - pkg: Install container-selinux

Install containerd:
  {{ pkg_installed('containerd') }}
    - require:
      - test: Repositories configured
      - pkg: Install runc
      - pkg: Install container-selinux

Configure registry IP in containerd conf:
  file.managed:
    - name: /etc/containerd/config.toml
    - makedirs: true
    - contents: |
        [plugins]
          [plugins.cri]
            [plugins.cri.registry]
              [plugins.cri.registry.mirrors]
                [plugins.cri.registry.mirrors."{{ pillar.registry_ip }}"]
                  endpoint = ["http://{{ pillar.registry_ip }}:5000"]
    - require:
      - pkg: Install containerd
