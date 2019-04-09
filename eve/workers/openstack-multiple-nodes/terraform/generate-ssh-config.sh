#!/usr/bin/env bash

set -xv

# Default values
SSH_CONFIG_FILE=ssh_config
IDENTITY_FILE=/home/eve/.ssh/terraform
NODES_COUNT=2

# Arguments parsing
while (( "$#" )); do
  case "$1" in
    -f|--filename)
      SSH_CONFIG_FILE=$2
      shift 2
      ;;
    -c|--nodes-count)
      NODES_COUNT=$2
      shift 2
      ;;
    *)
      echo "Error: unsupported argument $1" >&2
      exit 1
      ;;
  esac
done

# Retrieve an IP from Terraform state
#
# Examples:
#   get_ip router
#   get_ip nodes 0
get_ip() {
    local query
    query=".value.$1"
    [[ $2 ]] && query="$query[$2]"
    terraform output -json ips | jq -r "$query"
}

# Generate a section of the final SSH config file
print_host_config() {
    local NAME IP
    NAME=$1
    IP=$2

    cat << EOF
Host $NAME
    User centos
    Port 22
    Hostname $IP
    IdentityFile $IDENTITY_FILE
    IdentitiesOnly yes
    StrictHostKeyChecking no

EOF
}

# Main procedure

print_host_config router "$(get_ip router)" > "$SSH_CONFIG_FILE"
print_host_config bootstrap "$(get_ip bootstrap)" >> "$SSH_CONFIG_FILE"

# FIXME: this needs Terraform v0.12 to work (see ./nodes.tf)
# for idx in `seq 1 $NODES_COUNT`; do
#     print_host_config "node$idx" "$(get_ip nodes "$(expr $idx - 1)")" >> "$SSH_CONFIG_FILE"
# done
