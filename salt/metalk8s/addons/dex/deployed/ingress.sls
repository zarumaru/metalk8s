#!kubernetes kubeconfig=/etc/kubernetes/admin.conf&context=kubernetes-admin@kubernetes

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: dex-ingress
  namespace: kube-system
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    kubernetes.io/ingress.class: "nginx-control-plane"
  labels:
    app: dex
    app.kubernetes.io/managed-by: metalk8s
    app.kubernetes.io/name: dex
    app.kubernetes.io/part-of: metalk8s
    chart: dex-v2.19.0
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: dex
          servicePort: 5556