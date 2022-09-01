#!/usr/bin/bash
# Create storage volumes
lxc storage volume create local ceph01-disk1 size=50GiB --type=block --target lxc-01
lxc storage volume create local ceph01-disk2 size=50GiB --type=block --target lxc-01
lxc storage volume create local ceph02-disk1 size=50GiB --type=block --target lxc-02
lxc storage volume create local ceph02-disk2 size=50GiB --type=block --target lxc-02
lxc storage volume create local ceph03-disk1 size=50GiB --type=block --target lxc-03
lxc storage volume create local ceph03-disk2 size=50GiB --type=block --target lxc-03
#
# Create First Ceph Node
lxc init ubuntu:22.04 ceph01 --vm -p vlan30 -c limits.cpu=2 -c limits.memory=4GiB  --target lxc-01
lxc config device add ceph01 disk1 disk pool=local source=ceph01-disk1
lxc config device add ceph01 disk2 disk pool=local source=ceph01-disk2
#
# Create Second Ceph Node
lxc init ubuntu:22.04 ceph02 --vm -p vlan30 -c limits.cpu=2 -c limits.memory=4GiB --target lxc-02
lxc config device add ceph02 disk1 disk pool=local source=ceph02-disk1
lxc config device add ceph02 disk2 disk pool=local source=ceph02-disk2
#
# Create Third Ceph Node
lxc init ubuntu:22.04 ceph03 --vm -p vlan30 -c limits.cpu=2 -c limits.memory=4GiB --target lxc-03
lxc config device add ceph03 disk1 disk pool=local source=ceph03-disk1
lxc config device add ceph03 disk2 disk pool=local source=ceph03-disk2
#
# Start Ceph Nodes
lxc start ceph01
lxc start ceph02
lxc start ceph03

printf "Pause to allow VMs to start\n"
sleep 1m

# Change sshd_config to allow root login, public key authentication, and password authentication. 
# Restart sshd and set root password
CEPH_VMS=('ceph01' 'ceph02' 'ceph03')
for i in "${CEPH_VMS[@]}"
do
  lxc exec $i -- apt upgrade -y
  lxc exec $i -- sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 yes/' /etc/ssh/sshd_config
  lxc exec $i -- sed -i 's/#\?\(PubkeyAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config
  lxc exec $i -- sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 yes/' /etc/ssh/sshd_config
  lxc exec $i -- systemctl restart sshd
  printf "Set password for root\n"
  lxc exec $i -- passwd
done

# Copy ssh key to each ceph node
