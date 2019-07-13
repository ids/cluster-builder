#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo '>>> Installing base dependencies'
dnf install -y python3-devel libffi-devel openssl-devel gcc redhat-rpm-config open-vm-tools

cd /root
echo '>>> Upgrading pip3'
pip3 install --upgrade pip3

# Avoid bug in default python cryptography library
# [WARNING]: Optional dependency 'cryptography' raised an exception, falling back to 'Crypto'
echo '>>> Upgrading python cryptography library'
pip3 install --upgrade cryptography

echo '>>> Installing Ansible'
pip3 install ansible==2.8.2
