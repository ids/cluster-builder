#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Instructions from https://flatpacklinux.com/2016/05/27/install-ansible-2-1-on-rhelcentos-7-with-pip/

echo '>>> Updating'
yum makecache fast

echo '>>> Installing yum-utils'
yum install -y yum-utils

# Add the EPEL repository, and install Ansible.
echo '>>> Adding EPEL yum repo'
yum install -y epel-release
yum repolist

echo '>>> Updating'
yum makecache fast

echo '>>> Cleaning yum cache'
yum clean all

export PATH=/usr/local/bin:$PATH

echo '>>> Installing general dependencies'
yum install -y libffi-devel openssl-devel gcc redhat-rpm-config open-vm-tools

echo '>>> Installing Ansible'
yum install -y ansible
