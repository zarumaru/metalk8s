#!/bin/bash

VERSION=$1
HOSTNAME=$2
IP_ADDRESS=$3
ROLES=$4

WORK_DIR=$(mktemp -d)
NODE_MANIFEST=$WORK_DIR/$HOSTNAME.manifest

# shellcheck disable=SC2034
cat > "$NODE_MANIFEST" << EOF
apiVersion: v1
kind: Node
metadata:
  name: '$HOSTNAME'
  annotations:
    metalk8s.scality.com/ssh-key-path: '/etc/metalk8s/pki/bastion'
    metalk8s.scality.com/ssh-host: '$IP_ADDRESS'
    metalk8s.scality.com/ssh-sudo: 'true'
    metalk8s.scality.com/ssh-user: 'centos'
  labels:
    metalk8s.scality.com/version: '$VERSION'
$(for ROLE in $ROLES; do
cat - <<EOT
    node-role.kubernetes.io/$ROLE: ''"
EOT
done)
spec:
  taints:
$(for ROLE in $ROLES; do
    cat - <<EOT
  - effect: NoSchedule
    key: node-role.kubernetes.io/$ROLE
EOT
done)
EOF

echo -e "Applying the following node manifest:\n"
cat "$NODE_MANIFEST"

kubectl apply -f "$NODE_MANIFEST"

SALT_MASTER_CONTAINER_ID=$(
    crictl ps -q --label io.kubernetes.pod.namespace=kube-system \
                 --label io.kubernetes.container.name=etcd \
                 --state Running
)

PILLAR=(
  "{"
  "  'orchestrate': {"
  "    'node_name': '$HOSTNAME'"
  "  }"
  "}"
)

echo -e "Deploying the node through Salt:\n"

crictl exec -i "$SALT_MASTER_CONTAINER_ID" \
    salt-run state.orchestrate metalk8s.orchestrate.deploy_node \
    saltenv="metalk8s-$VERSION" \
    pillar="${PILLAR[*]}"
