#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH=/usr/local/bin:$PATH

echo '>>> Installing pip3 (and dependencies)'
dnf install -y python36
dnf install -y python3-pip
dnf install -y python3-devel.x86_64 libffi-devel openssl-devel gcc redhat-rpm-config open-vm-tools

python3 --version
which pip3
pip3 --version

pip3 install --upgrade pip
pip --version

# Avoid bug in default python cryptography library
# [WARNING]: Optional dependency 'cryptography' raised an exception, falling back to 'Crypto'
echo '>>> Upgrading python cryptography library'
pip install --upgrade cryptography

echo '>>> Installing Ansible'
pip install ansible==2.7.8

echo '>>> Ansible Should be Using Python3'
ansible --version