#!/usr/bin/bash
# Stop Ceph Nodes
lxc stop ceph01 ceph02 ceph03
lxc delete ceph01 ceph02 ceph03

# Delete storage volumes
lxc storage volume delete local ceph01-disk1
lxc storage volume delete local ceph01-disk2
lxc storage volume delete local ceph02-disk1
lxc storage volume delete local ceph02-disk2
lxc storage volume delete local ceph03-disk1
lxc storage volume delete local ceph03-disk2