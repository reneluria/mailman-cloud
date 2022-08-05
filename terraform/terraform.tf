# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

locals {
  ssh_ipv4_prefixes = [
    "10.3.3.0/24",
    "10.8.0.0/16",
  ]
  ssh_ipv6_prefixes = [
    "2001:1600:2:f::/64",
    "2001:1600:4:3::dead/128",
    "2001:1600:0:cccc::/64",
  ]
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTs8LdRkaAAGox8vCJcK44N5NtFW8kJ+2txSeV4QeDc tf-keypair"
}

resource "openstack_images_image_v2" "bullseye" {
  name             = "debian-11-genericcloud-amd64-20220503-998"
  image_source_url = "https://cloud.debian.org/images/cloud/bullseye/20220503-998/debian-11-genericcloud-amd64-20220503-998.qcow2"
  container_format = "bare"
  disk_format      = "qcow2"

  properties = {
    os_admin_user     = "debian"
    os_distro         = "debian"
    os_type           = "linux"
    provider_codename = "bullseye"
    provider_name     = "Debian"
  }
}

resource "openstack_networking_secgroup_v2" "sec_mailman" {
  name        = "sec_mailman"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_ipv4" {
  count             = length(local.ssh_ipv4_prefixes)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = local.ssh_ipv4_prefixes[count.index]
  security_group_id = "${openstack_networking_secgroup_v2.sec_mailman.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_ipv6" {
  count             = length(local.ssh_ipv6_prefixes)
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = local.ssh_ipv6_prefixes[count.index]
  security_group_id = "${openstack_networking_secgroup_v2.sec_mailman.id}"
}

resource "openstack_networking_secgroup_rule_v2" "http_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = "${openstack_networking_secgroup_v2.sec_mailman.id}"
}

resource "openstack_networking_secgroup_rule_v2" "http_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = "${openstack_networking_secgroup_v2.sec_mailman.id}"
}

resource "openstack_networking_secgroup_rule_v2" "https_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = "${openstack_networking_secgroup_v2.sec_mailman.id}"
}

resource "openstack_networking_secgroup_rule_v2" "https_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = "${openstack_networking_secgroup_v2.sec_mailman.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = "${openstack_networking_secgroup_v2.sec_mailman.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  security_group_id = "${openstack_networking_secgroup_v2.sec_mailman.id}"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "tf-keypair"
  public_key = local.public_key
}

resource "openstack_compute_instance_v2" "instance" {
  name            = "mailman"
  image_id        = "${openstack_images_image_v2.bullseye.id}"
  flavor_name       = "a1-ram2-disk20-perf1"
  key_pair        = "tf-keypair"
  security_groups = ["sec_mailman"]

  network {
    name = "ext-net1"
  }

  depends_on = [
    openstack_compute_keypair_v2.keypair
  ]
}

output "ipv4_address" {
  value = openstack_compute_instance_v2.instance.access_ip_v4
}

output "ipv6_address" {
  value = openstack_compute_instance_v2.instance.access_ip_v6
}
