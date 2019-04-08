resource "openstack_compute_instance_v2" "bootstrap" {
  name        = "${local.prefix}-bootstrap"
  image_name  = "${var.openstack_image_name}"
  flavor_name = "${var.openstack_flavour_name}"
  key_pair    = "${openstack_compute_keypair_v2.local_ssh_key.name}"
  security_groups = [
    "${openstack_networking_secgroup_v2.nodes.name}",
    "${openstack_networking_secgroup_v2.nodes_internal.name}"
  ]

  network = ["${var.openstack_network}"]

  # Private networks
  network {
    name = "${openstack_networking_network_v2.control_plane.name}"
  }
  network {
    name = "${openstack_networking_network_v2.workload_plane.name}"
  }
  # We need the subnets to be created before attempting to reach the DHCP server
  depends_on = [
    "openstack_networking_subnet_v2.control_plane_subnet",
    "openstack_networking_subnet_v2.workload_plane_subnet",
  ]

  connection {
    user     = "centos"
    private_key = "${file("~/.ssh/terraform")}"
  }

  # Obtain IP addresses for both private networks
  provisioner "remote-exec" {
    inline = [
      "sudo chattr +i /etc/resolv.conf",
      "sudo dhclient -r -v eth1 eth2",
      "sudo dhclient -v eth1 eth2",
    ]
  }

  # Copy the IP-IP tunnel setup script only on the bootstrap node
  provisioner "file" {
    source      = "setup-ipip-tunnel.sh"
    destination = "/home/centos/setup-ipip-tunnel.sh"
  }
}

output "bootstrap_ip" {
  value = "${openstack_compute_instance_v2.bootstrap.network.0.fixed_ip_v4}"
}

variable "nodes_count" {
  type    = "string"
  default = "1"
}

resource "openstack_compute_instance_v2" "nodes" {
  name        = "${local.prefix}-node-${count.index+1}"
  image_name  = "${var.openstack_image_name}"
  flavor_name = "${var.openstack_flavour_name}"
  key_pair    = "${openstack_compute_keypair_v2.local_ssh_key.name}"
  security_groups = [
    "${openstack_networking_secgroup_v2.nodes.name}",
    "${openstack_networking_secgroup_v2.nodes_internal.name}"
  ]

  network = ["${var.openstack_network}"]

  # Private networks
  network {
    name = "${openstack_networking_network_v2.control_plane.name}"
  }
  network {
    name = "${openstack_networking_network_v2.workload_plane.name}"
  }
  # We need the subnets to be created before attempting to reach the DHCP server
  depends_on = [
    "openstack_networking_subnet_v2.control_plane_subnet",
    "openstack_networking_subnet_v2.workload_plane_subnet",
  ]

  # Obtain IP addresses for both private networks
  provisioner "remote-exec" {
    inline = [
      "sudo chattr +i /etc/resolv.conf",
      "sudo dhclient -r -v eth1 eth2",
      "sudo dhclient -v eth1 eth2",
    ]
    connection {
      user     = "centos"
      private_key = "${file("~/.ssh/terraform")}"
    }
  }

  count = "${var.nodes_count}"
}
