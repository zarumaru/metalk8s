#!jinja | kubernetes kubeconfig=/etc/kubernetes/admin.conf&context=kubernetes-admin@kubernetes
{%- from "metalk8s/repo/macro.sls" import build_image_name with context %}

{% raw %}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/instance: dex
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: dex
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 2.19.0
    helm.sh/chart: dex-2.4.0
    heritage: metalk8s
  name: dex
  namespace: metalk8s-auth
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/instance: dex
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: dex
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 2.19.0
    helm.sh/chart: dex-2.4.0
    heritage: metalk8s
  name: dex
  namespace: metalk8s-auth
rules:
- apiGroups:
  - dex.coreos.com
  resources:
  - '*'
  verbs:
  - '*'
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/instance: dex
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: dex
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 2.19.0
    helm.sh/chart: dex-2.4.0
    heritage: metalk8s
  name: dex
  namespace: metalk8s-auth
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dex
subjects:
- kind: ServiceAccount
  name: dex
  namespace: metalk8s-auth
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: dex
    app.kubernetes.io/instance: dex
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: dex
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 2.19.0
    helm.sh/chart: dex-2.4.0
    heritage: metalk8s
  name: dex
  namespace: metalk8s-auth
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/component: dex
      app.kubernetes.io/instance: dex
      app.kubernetes.io/name: dex
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      annotations:
        checksum/config: 29e3df85dbf3c8bf90be8932432641ec24fc45691db16bbc9cf390c30c583e5e
      labels:
        app.kubernetes.io/component: dex
        app.kubernetes.io/instance: dex
        app.kubernetes.io/name: dex
    spec:
      containers:
      - command:
        - /usr/local/bin/dex
        - serve
        - /etc/dex/cfg/config.yaml
        env: []
        image: '{%- endraw -%}{{ build_image_name("dex", False) }}{%- raw -%}:v2.19.0'
        imagePullPolicy: IfNotPresent
        name: main
        ports:
        - containerPort: 5556
          name: https
          protocol: TCP
        resources: null
        volumeMounts:
        - mountPath: /etc/dex/cfg
          name: config
        - mountPath: /etc/dex/tls/https/server
          name: https-tls
      nodeSelector:
        node-role.kubernetes.io/infra: ''
      serviceAccountName: dex
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/bootstrap
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/infra
        operator: Exists
      volumes:
      - name: config
        secret:
          defaultMode: 420
          items:
          - key: config.yaml
            path: config.yaml
          secretName: dex
      - name: https-tls
        secret:
          defaultMode: 420
          secretName: dex-web-server-tls

{% endraw %}
