#!/usr/bin/env bash

echo '***'
echo '*** Setting up authorized keys...'
echo '***'

if [ ! -d /home/admin/.ssh ]; then 
  mkdir /home/admin/.ssh
  chmod 700 /home/admin/.ssh
fi 
cp /tmp/authorized_keys /home/admin/.ssh/authorized_keys
chmod 600 /home/admin/.ssh/authorized_keys
chown admin:admin -R /home/admin/.ssh

echo '*** Adding OpenVMTools'
rpm-ostree pkg-add open-vm-tools
echo '*** Adding NFS Utils'
rpm-ostree pkg-add nfs-utils
echo '*** Adding Curl'
rpm-ostree pkg-add curl
echo '*** Adding Python PIP'
rpm-ostree pkg-add pyton-pip
echo '*** Adding Docker Compose'
rpm-ostree pkg-add docker-compose

