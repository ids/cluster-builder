#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH=/usr/local/bin:$PATH

echo '>>> Installing general dependencies'
dnf install -y libffi-devel openssl-devel gcc redhat-rpm-config open-vm-tools

echo '>>> Installing Ansible'
dnf install -y ansible

ln -s /usr/bin/python3 /usr/bin/python

