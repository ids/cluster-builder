#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo '>>> Installing pip (and dependencies)'
dnf install -y python-devel libffi-devel openssl-devel gcc python-pip redhat-rpm-config open-vm-tools

echo '>>> Upgrading pip'
pip install --upgrade pip

# Avoid bug in default python cryptography library
# [WARNING]: Optional dependency 'cryptography' raised an exception, falling back to 'Crypto'
echo '>>> Upgrading python cryptography library'
pip install --upgrade cryptography

echo '>>> Installing Ansible'
pip install ansible==2.4.1
