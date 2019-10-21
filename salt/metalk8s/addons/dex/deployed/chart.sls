#!jinja | kubernetes kubeconfig=/etc/kubernetes/admin.conf&context=kubernetes-admin@kubernetes
{%- from "metalk8s/repo/macro.sls" import build_image_name with context %}

apiVersion: v1
kind: ServiceAccount
metadata:
  name: dex
  namespace: kube-system
  labels:
    app: dex
    app.kubernetes.io/managed-by: metalk8s
    app.kubernetes.io/name: dex
    app.kubernetes.io/part-of: metalk8s
    chart: dex-v2.19.0
    heritage: metalk8s
    release: dex
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: dex
  namespace: kube-system
rules:
- apiGroups: ["dex.coreos.com"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dex-reader
  namespace: kube-system
rules:
- apiGroups:
  - ""
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: dex
    app.kubernetes.io/managed-by: metalk8s
    app.kubernetes.io/name: dex
    app.kubernetes.io/part-of: metalk8s
    chart: dex-v2.19.0
  name: dex
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dex
subjects:
- kind: ServiceAccount
  name: dex
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: dex
    app.kubernetes.io/managed-by: metalk8s
    app.kubernetes.io/name: dex
    app.kubernetes.io/part-of: metalk8s
    chart: dex-v2.19.0
  name: dex-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dex-reader
subjects:
- kind: ServiceAccount
  name: dex
  namespace: kube-system
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dex
  namespace: kube-system
rules:
- apiGroups: [""]
  resources: ["services", "configmaps", "secrets"]
  resourceNames: ["dex"]
  verbs: ["get", "create", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dex
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: dex
subjects:
- kind: ServiceAccount
  name: dex
  namespace: kube-system
- kind: Group
  name: dex
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  name: dex
  namespace: kube-system
  labels:
    app: dex
    app.kubernetes.io/name: dex
    component: identity
spec:
  #type: ExternalName
  #externalName: dex.kube-system.svc.cluster.local
  selector:
    app: dex
    component: identity
  ports:
  - name: dex
    port: 5556
    protocol: TCP
    targetPort: 5556
---
apiVersion: v1
kind: Secret
metadata:
  name:  dex
  namespace: kube-system
  labels:
    dex: superuser
data:
  email: YWRtaW5AZXhhbXBsZS5jb20=
  username: YWRtaW4=
  password: YWRtaW4=
type: Opaque
---
apiVersion: v1
kind: Secret
metadata:
  name:  dex-reader
  namespace: kube-system
  labels:
    dex: reader
data:
  email: cmVhZG9ubHlAZXhhbXBsZS5jb20=20=
  username: dXNlcg==
  password: dXNlcg==
type: Opaque
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: dex
  namespace: kube-system
data:
  config.yaml: |
    issuer: http://127.0.0.1:5556 # replace with your url
    storage:
      type: kubernetes
      config:
        inCluster: true
    web:
      http: 0.0.0.0:5556
      # Uncomment for HTTPS options.
      # https: 127.0.0.1:5556
      # tlsCert: /etc/dex/tls.crt
      # tlsKey: /etc/dex/tls.key
    #connectors:
    #  - type: oidc
    #    id: oidc
    #    name: OIDC  # add real provider
    oauth2:
      skipApprovalScreen: true
    staticClients:
    - id: kubernetes
      redirectURIs:
      - 'urn:ietf:wg:oauth:2.0:oob' # No need to redirect to anywhere
      name: "Kubernetes"
      secret: "ZXhhbXBsZS1hcHAtc2VjcmV0"

    - id: metalk8s-ui
      redirectURIs:
      - 'https://{{ grains.metalk8s.control_plane_ip }}:8443/oidc/done'
      name: "MetalK8s UI App"
      secret: "ZXhhbXBsZS1hcHAtc2VjcmV0"

    - id: grafana-app # can be grafana
      secret: example-app-secret
      name: 'Grafana Example'
      # Where the app will be running.
      redirectURIs:
      - 'http://127.0.0.1:5555/callback'
    enablePasswordDB: true

    staticPasswords:
    - email: "admin@superuser.com"
      # bcrypt hash of the string "password"
      hash: "$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"
      username: "admin"
      userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: dex
  namespace: kube-system
  labels:
    app: dex
    component: identity
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ''
spec:
  replicas: 3
  minReadySeconds: 30
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      name: dex
      labels:
        app: dex
        component: identity
    spec:
      volumes:
      - name: config
        configMap:
          name: dex
          items:
          - key: config.yaml
            path: config.yaml
      - name: superuser
        secret:
          secretName: dex
      - name: ca
        hostPath:
          path: /etc/kubernetes/pki/ca.crt
      containers:
      - name: dex
        imagePullPolicy: IfNotPresent
        image: '{{ build_image_name("dex") }}'
        command: ["/usr/local/bin/dex", "serve", "/etc/dex/cfg/config.yaml"]
        volumeMounts:
        - name: config
          mountPath: /etc/dex/cfg
        - name: superuser
          mountPath: /etc/dex/admin
        - name: ca
          mountPath: /etc/kubernetes/pki/ca.crt
        ports:
        - containerPort: 5556
          name: https
          protocol: TCP
        resources:
          requests:
            cpu: 100m
            memory: 50Mi
          limits:
            cpu: 100m
            memory: 50Mi
      nodeSelector:
        node-role.kubernetes.io/infra: ''
      terminationGracePeriodSeconds: 60
      serviceAccountName: dex
      restartPolicy: Always
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/bootstrap
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/infra
        operator: Exists
