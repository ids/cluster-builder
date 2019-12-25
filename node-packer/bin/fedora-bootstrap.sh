#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo '>>> Installing base dependencies'
dnf install -y python3 python3-pip python3-devel libffi-devel openssl-devel gcc redhat-rpm-config open-vm-tools

echo '>>> Installing ansible'
pip3 install ansible

