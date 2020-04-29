#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo '>>> Installing base dependencies'
dnf makecache
dnf install -y python3 python3-pip python3-devel libffi-devel openssl-devel gcc redhat-rpm-config open-vm-tools

echo '>>> Installing ansible'
pip3 install ansible

#echo '>>> Installing docker-ce'
#sudo dnf -y install dnf-plugins-core

#sudo tee /etc/yum.repos.d/docker-ce.repo<<EOF
#[docker-ce-stable]
#name=Docker CE Stable - \$basearch
#baseurl=https://download.docker.com/linux/fedora/31/\$basearch/stable
#enabled=1
#gpgcheck=1
#gpgkey=https://download.docker.com/linux/fedora/gpg
#EOF

#sudo dnf makecache
#sudo dnf -y install docker-ce docker-ce-cli containerd.io

echo '>>> Switch to CGroup v1'
dnf install -y grubby
grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"