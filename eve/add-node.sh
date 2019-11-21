#!/bin/bash

KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}
NODE_NAME=${NODE_NAME:-}
SSH_HOST=${SSH_HOST:-}
SSH_KEY=${SSH_KEY:-}
SSH_USER=${SSH_USER:-}
VERSION=${VERSION:-}
SHORT_OPTS=c:hn:r:H:k:u:v:
LONG_OPTS="
  kubeconfig:,
  help,
  name:,
  role:,
  ssh-host:,
  ssh-key:,
  ssh-user:,
  version:,
"
declare -A MANDATORY_OPTIONS=(
  [KUBECONFIG]='--kubeconfig'
  [NODE_NAME]='--name'
  [ROLES]='--role'
  [SSH_HOST]='--ssh-host'
  [SSH_KEY]='--ssh-key'
  [SSH_USER]='--ssh-user'
  [VERSION]='--version'
)

usage() {
    cat - << EOF
Usage:
${0##*/} [options]

Options:
-c, --kubeconfig FILE  Path to the kubeconfig file
-h, --help             Display this message and exit
-n, --name NAME        Name of the node to deploy
-r, --role ROLE        Role of the node, can be provided multiple times
-H, --ssh-host HOST    Hostname or IP address to access to the node
-k, --ssh-key FILE     Identity file used to connect to the node via SSH
-u, --ssh-user USER    Username used to connect to the node via SSH
-v, --version VERSION  Version of MetalK8s to deploy on the node
EOF
}

if ! OPTS=$(getopt --options "$SHORT_OPTS" --long "$LONG_OPTS" -- "$@"); then
    echo 1>&2 "Incorrect arguments provided"
    usage
    exit 1
fi

eval set -- "$OPTS"

while :; do
    case "$1" in
        -c|--kubeconfig)
            KUBECONFIG=$2
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -n|--name)
            NODE_NAME=$2
            shift
            ;;
        -r|--role)
            ROLES+=("$2")
            shift
            ;;
        -H|--ssh-host)
            SSH_HOST=$2
            shift
            ;;
        -k|--ssh-key)
            SSH_KEY=$2
            shift
            ;;
        -u|--ssh-user)
            SSH_USER=$2
            shift
            ;;
        -v|--version)
            VERSION=$2
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo 1>&2 "Option parsing failure"
            exit 1
            ;;
    esac
    shift
done

for OPTION in "${!MANDATORY_OPTIONS[@]}"; do
    if [[ ! ${!OPTION} ]]; then
        echo 1>&2 "Error: ${MANDATORY_OPTIONS[$OPTION]} option is mandatory"
        exit 1
    fi
done

WORK_DIR=$(mktemp -d)
NODE_MANIFEST=$WORK_DIR/$NODE_NAME.manifest

# shellcheck disable=SC2034
cat > "$NODE_MANIFEST" << EOF
apiVersion: v1
kind: Node
metadata:
  name: '$NODE_NAME'
  annotations:
    metalk8s.scality.com/ssh-key-path: '$SSH_KEY'
    metalk8s.scality.com/ssh-host: '$SSH_HOST'
    metalk8s.scality.com/ssh-sudo: 'true'
    metalk8s.scality.com/ssh-user: '$SSH_USER'
  labels:
    metalk8s.scality.com/version: '$VERSION'
$(for ROLE in "${ROLES[@]}"; do
    cat - <<EOT
    node-role.kubernetes.io/$ROLE: ''
EOT
done)
spec:
  taints:
$(for ROLE in "${ROLES[@]}"; do
    cat - <<EOT
  - effect: NoSchedule
    key: node-role.kubernetes.io/$ROLE
EOT
done)
EOF

echo -e "Applying the following node manifest:\n"
cat "$NODE_MANIFEST"

kubectl --kubeconfig "$KUBECONFIG" apply -f "$NODE_MANIFEST"

SALT_MASTER_CONTAINER_ID=$(
    crictl ps -q --label io.kubernetes.pod.namespace=kube-system \
                 --label io.kubernetes.container.name=salt-master \
                 --state Running
)

PILLAR=(
  "{"
  "  'orchestrate': {"
  "    'node_name': '$NODE_NAME'"
  "  }"
  "}"
)

echo -e "Deploying the node through Salt:\n"

crictl exec -i "$SALT_MASTER_CONTAINER_ID" \
    salt-run state.orchestrate metalk8s.orchestrate.deploy_node \
    saltenv="metalk8s-$VERSION" \
    pillar="${PILLAR[*]}"
