{%- from "metalk8s/macro.sls" import pkg_installed with context %}
{%- from "metalk8s/map.jinja" import kubelet with context %}

include:
  - metalk8s.repo
{%- if kubelet.container_engine %}
  - metalk8s.container-engine.{{ kubelet.container_engine }}
{%- endif %}

Install and configure cri-tools:
  {{ pkg_installed('cri-tools') }}
    - require:
      - test: Repositories configured
  file.serialize:
    - name: /etc/crictl.yaml
    - dataset:
        runtime-endpoint: {{ kubelet.service.options.get("container-runtime-endpoint") }}
        image-endpoint: {{ kubelet.service.options.get("container-runtime-endpoint") }}
    - merge_if_exists: true
    - user: root
    - group: root
    - mode: '0644'
    - formatter: yaml

Install kubelet:
  {{ pkg_installed('kubelet') }}
    - require:
      - test: Repositories configured