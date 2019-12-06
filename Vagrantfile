# -*- mode: ruby -*-
# vi: set ft=ruby ts=2 sw=2 expandtab :
# frozen_string_literal: true

require 'ipaddr'

if File.exists?('vagrant_config.rb')
  require_relative 'vagrant_config'
else
  RHSM_USERNAME = ''
  RHSM_PASSWORD = ''
  RHSM_POOL = ''
end

# $ ipcalc 172.21.254.0/255.255.255.240
# Network:        172.21.254.0/28
# Netmask:        255.255.255.240 = 28
# Broadcast:      172.21.254.15
#
# Address space:  Private Use
# Address class:  Class B
# HostMin:        172.21.254.1
# HostMax:        172.21.254.14
# Hosts/Net:      14
CONTROL_PLANE_IP = '172.21.254.0'
CONTROL_PLANE_NETMASK = '255.255.255.240'
CONTROL_PLANE_NETWORK = {
  :ip => CONTROL_PLANE_IP,
  :netmask => CONTROL_PLANE_NETMASK,
  # This seems to be set incorrectly (to an address outside the ip/netmask
  # range) when using auto-configuration with Vagrant 2.1.2. Setting it to the
  # value that would be auto-configured when using current Vagrant 'master'
  # works just fine.
  # See
  # https://github.com/hashicorp/vagrant/blob/v2.1.2/plugins/providers/virtualbox/action/network.rb#L326
  # and
  # https://github.com/hashicorp/vagrant/blob/1e1c398de565ed0aab9631cfad2db6e1dac82d7f/plugins/providers/virtualbox/action/network.rb#L317
  # or https://github.com/hashicorp/vagrant/pull/7699
  # Also, we leave off the 'last' IP in the control-plane network, which is
  # reserved as the VIP of the API server.
  :dhcp_upper => IPAddr.new(CONTROL_PLANE_IP).mask(CONTROL_PLANE_NETMASK).to_range.last(3).first.to_s,
}

# Bigger network for the workload plane. However, we only allow DHCP to allocate
# in the first /28 network (similar to CONTROL_PLANE_NETWORK), and the other
# half is used for the LB VIPs.
#
# $ ipcalc 172.21.254.32/27
# Network:        172.21.254.32/27
# Netmask:        255.255.255.224 = 27
# Broadcast:      172.21.254.63
#
# Address space:  Private Use
# Address class:  Class B
# HostMin:        172.21.254.33
# HostMax:        172.21.254.62
# Hosts/Net:      30
WORKLOAD_PLANE_IP = '172.21.254.32'
WORKLOAD_PLANE_NETMASK = '255.255.255.224'
WORKLOAD_PLANE_DHCP_RANGE = '255.255.255.240'
# This leaves .47 - .62 for LB VIPs
WORKLOAD_PLANE_NETWORK = {
  :ip => WORKLOAD_PLANE_IP,
  :netmask => WORKLOAD_PLANE_NETMASK,
  # Need to explicitly set this value, otherwise the DHCP server could allocate
  # addresses we reserve for the LB VIPs
  :dhcp_upper => IPAddr.new(WORKLOAD_PLANE_IP).mask(WORKLOAD_PLANE_DHCP_RANGE).to_range.last(2).first.to_s,
}

def prefixlen(s)
  s.split('.').map{ |p| p.to_i.to_s(2) }.join.count('1')
end

IMPORT_RELEASE = <<-SCRIPT
#!/bin/bash

set -eu -o pipefail

RC=0

source /vagrant/_build/root/product.txt

die() {
    echo 1>&2 $@
    exit 1
}

echo "Installing build artifacts on the host"

mkdir -p /srv/scality || die "Failed to create /srv/scality"
rm -f "/srv/scality/metalk8s-$VERSION" || die "Failed to unlink symlink destination"
ln -s /vagrant/_build/root "/srv/scality/metalk8s-$VERSION" || die "Failed to create symlink"

echo "Installed build artifacts on the host"

echo "Disabling swap"
swapoff -a
echo "Swap disabled"

exit $RC
SCRIPT

PRESHARED_SSH_KEY_NAME = 'preshared_key_for_k8s_nodes'
IMPORT_SSH_PRIVATE_KEY = <<-SCRIPT
#!/bin/bash

set -eu -o pipefail

echo "Deploying preshared SSH private key on the host"

mkdir -p /etc/metalk8s/pki/
cp /vagrant/.vagrant/#{PRESHARED_SSH_KEY_NAME} /etc/metalk8s/pki/

echo "Deployed preshared SSH private key on the host"
SCRIPT

BOOTSTRAP = <<-SCRIPT
#!/bin/bash

set -eu -o pipefail

source /vagrant/_build/root/product.txt

if ! test -x "/srv/scality/metalk8s-$VERSION/bootstrap.sh"; then
    echo 1>&2 "Bootstrap script not found in build directory."
    echo 1>&2 "Did you run 'make'?"
    exit 1
fi

echo "Creating bootstrap configuration"
cat > /etc/metalk8s/bootstrap.yaml << EOF
apiVersion: metalk8s.scality.com/v1alpha2
kind: BootstrapConfiguration
networks:
  controlPlane: #{CONTROL_PLANE_IP}/#{prefixlen(CONTROL_PLANE_NETMASK)}
  workloadPlane: #{WORKLOAD_PLANE_IP}/#{prefixlen(WORKLOAD_PLANE_NETMASK)}
ca:
  minion: bootstrap
archives:
  - /srv/scality/metalk8s-$VERSION
EOF

echo "Launching bootstrap"
exec "/srv/scality/metalk8s-$VERSION/bootstrap.sh"
SCRIPT

CREATE_VOLUMES = File.read(__dir__ + "/eve/create-volumes.sh")

DEPLOY_SSH_PUBLIC_KEY = <<-SCRIPT
#!/bin/bash

set -eu -o pipefail

if ! grep -Fxq "$(cat .ssh/#{PRESHARED_SSH_KEY_NAME}.pub)" .ssh/authorized_keys ; then
   cat .ssh/#{PRESHARED_SSH_KEY_NAME}.pub >> .ssh/authorized_keys
fi
SCRIPT

UPDATE_REPO = 'DEBIAN_FRONTEND=noninteractive apt update -yq'
INSTALL_PYTHON = 'DEBIAN_FRONTEND=noninteractive apt install python -yq'

RHSM_REGISTER = <<-SCRIPT
#!/bin/bash

set -eu

if ! [[ "#{RHSM_USERNAME}" && "#{RHSM_PASSWORD}" && "#{RHSM_POOL}" ]]; then
    echo "You must set RHSM_USERNAME, RHSM_PASSWORD & RHSM_POOL" \
         "in vagrant_config.rb in order to spawn VM on RedHat." >&2
    exit 1
fi

subscription-manager register --username="#{RHSM_USERNAME}" \
                              --password="#{RHSM_PASSWORD}"
subscription-manager attach --pool="#{RHSM_POOL}"
subscription-manager repos --enable=rhel-7-server-optional-rpms \
                           --enable=rhel-7-server-extras-rpms
SCRIPT
RHSM_UNREGISTER = 'subscription-manager unregister || true'

# To support VirtualBox linked clones
Vagrant.require_version(">= 1.8")

def declare_bootstrap(machine, os_data)
  machine.vm.box = os_data[:name]
  machine.vm.box_version = os_data[:version]

  machine.vm.hostname = "bootstrap"
  machine.vm.provider "virtualbox" do |v|
    v.memory = 4086
    machine.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  end

  if os_data.fetch(:scripts, []).each do |script|
       machine.vm.provision script[:name],
         type: script[:type],
         inline: script[:data]
     end
  end

  if os_data.fetch(:triggers_before, []).each do |trigger|
        machine.trigger.before trigger[:on].to_sym,
          info: trigger[:info],
          run_remote: trigger[:run],
          on_error: :continue
      end
  end

  machine.vm.provision "import-release",
    type: "shell",
    inline: IMPORT_RELEASE

  machine.vm.provision "import-ssh-private-key",
    type: "shell",
    inline: IMPORT_SSH_PRIVATE_KEY

  machine.vm.provision "bootstrap",
    type: "shell",
    inline: BOOTSTRAP

  machine.vm.provision "create-volumes",
    type: "shell",
    inline: CREATE_VOLUMES

  machine
end

Vagrant.configure("2") do |config|

  os_data = {
    centos: {
      name: 'centos/7',
      version: '1811.02'
    },
    ubuntu: {
      name: 'ubuntu/bionic64',
      version: '20190514.0.0',
      scripts: [
        {
          name: 'update-repository-list',
          type: 'shell',
          data: UPDATE_REPO,
        },
        {
          name: 'install-python',
          type: 'shell',
          data: INSTALL_PYTHON
        }
      ]
    },
    redhat: {
      name: 'generic/rhel7',
      version: '1.9.36',
      scripts: [
        {
          name: 'rhsm-register',
          type: 'shell',
          data: RHSM_REGISTER
        }
      ],
      triggers_before: [
        {
          on: 'destroy',
          info: 'Unregistering host from RHSM',
          run: {inline: RHSM_UNREGISTER}
        }
      ]
    }
  }

  config.vm.box = os_data[:centos][:name]
  config.vm.box_version = os_data[:centos][:version]

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.memory = 2048
    v.cpus = 2
    v.customize ["modifyvm", :id, "--chipset", "ich9"]
  end

  config.vm.network "private_network",
    type: :dhcp,
    nic_type: 'virtio',
    **CONTROL_PLANE_NETWORK
  config.vm.network "private_network",
    type: :dhcp,
    nic_type: 'virtio',
    **WORKLOAD_PLANE_NETWORK

  config.vm.define :bootstrap, primary: true do |machine|
    declare_bootstrap machine, os_data[:centos]
  end

  config.vm.define :bootstrap_ubuntu, autostart: false do |machine|
    declare_bootstrap machine, os_data[:ubuntu]
  end

  config.vm.define :bootstrap_redhat, autostart: false do |machine|
    declare_bootstrap machine, os_data[:redhat]
  end

  os_data.each do |os, os_data|
    (1..5).each do |i|
      node_name = "#{os}#{i}"
      config.vm.define node_name, autostart: false do |node|

        node.vm.box = os_data[:name]
        node.vm.box_version = os_data[:version]

        node.vm.hostname = node_name

        node.vm.synced_folder ".", "/vagrant", disabled: true

        # No need for Guest Additions since there is no synced folder
        node.vbguest.auto_update = false

        node.vm.provision "copy-ssh-public-key",
          type: "file",
          source: ".vagrant/#{PRESHARED_SSH_KEY_NAME}.pub",
          destination: ".ssh/#{PRESHARED_SSH_KEY_NAME}.pub"

        node.vm.provision "add-ssh-public-key-to-authorized-keys",
          type: "shell",
          inline: DEPLOY_SSH_PUBLIC_KEY

        if os_data.fetch(:scripts, []).each do |script|
             node.vm.provision script[:name],
               type: script[:type],
               inline: script[:data]
           end
        end

        if os_data.fetch(:triggers_before, []).each do |trigger|
              node.trigger.before trigger[:on].to_sym,
                info: trigger[:info],
                run_remote: trigger[:run],
                on_error: :continue
            end
        end
      end
    end
  end
end
