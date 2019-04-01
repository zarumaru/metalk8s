#!/usr/bin/env bash

# Default values
IFNAME=tun0  # Name of the tunnel interface
TUNNEL_IP_PREFIX=192.168.42  # "Fake" network used for the tunnel
ON_WORKER=   # Whether this is the Eve worker or not
CONTROL_PLANE_CIDR=172.21.254.0/28
WORKLOAD_PLANE_CIDR=172.21.254.32/27

# Arguments parsing
while (( "$#" )); do
  case "$1" in
    -r|--remote-ip)
      REMOTE_IP=$2
      shift 2
      ;;
    -l|--local-ip)
      LOCAL_IP=$2
      shift 2
      ;;
    -t|--tunnel-ip-prefix)
      TUNNEL_IP_PREFIX=$2
      shift 2
      ;;
    -c|--control-plane)
      CONTROL_PLANE_CIDR=$2
      shift 2
      ;;
    -w|--workload-plane)
      WORKLOAD_PLANE_CIDR=$2
      shift 2
      ;;
    --eve-worker)
      ON_WORKER=1
      shift
      ;;
    --ifname)
      IFNAME=$2
      shift 2
      ;;
    *)
      echo "Error: unsupported argument $1" >&2
      exit 1
      ;;
  esac
done

if [ -z $REMOTE_IP ] ; then echo "Must provide a remote IP." ; fi
if [ -z $LOCAL_IP ] ; then echo "Must provide a local IP." ; fi

# Activate the IP-IP kernel module
modprobe ipip

# Create the tunnel interface
ip tunnel add "$IFNAME" mode ipip remote "$REMOTE_IP" local "$LOCAL_IP" ttl 255

# Set-up the tunnel interface
if [ $ON_WORKER ]; then
  TUNNEL_IP="$TUNNEL_IP_PREFIX.1"
else
  TUNNEL_IP="$TUNNEL_IP_PREFIX.2"
fi

ifconfig "$IFNAME" "$TUNNEL_IP" up

# Route the "fake" network through the tunnel interface
route add -net "$TUNNEL_IP_PREFIX.0/30" dev "$IFNAME"

if [ $ON_WORKER ]; then
  # Add routes for the networks to tunnel
  route add -net "$CONTROL_PLANE_CIDR" dev "$IFNAME"
  route add -net "$WORKLOAD_PLANE_CIDR" dev "$IFNAME"
else
  # Allow IP forwarding for the bootstrap node
  echo 1 > /proc/sys/net/ipv4/ip_forward
fi
