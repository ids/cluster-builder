#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo '>>> Installing yum-utils'
yum install -y yum-utils

echo '>>> Adding EPEL yum repo'
yum install -y epel-release
yum repolist

echo '>>> Updating'
yum makecache fast

echo '>>> Cleaning yum cache'
yum clean all

echo '>>> Installing base dependencies'
yum install -y python3-devel libffi-devel openssl-devel gcc redhat-rpm-config open-vm-tools ansible
