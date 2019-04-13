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
#yum-config-manager --add-repo=https://dl.fedoraproject.org/pub/epel/7/x86_64/
#curl --fail --location --silent --show-error --verbose -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

yum install -y epel-release
yum repolist

echo '>>> Updating'
yum makecache fast

echo '>>> Cleaning yum cache'
yum clean all

export PATH=/usr/local/bin:$PATH

echo '>>> Installing pip3 (and dependencies)'
yum install -y python36 python36-devel python36-setuptools python36-pip
yum install -y libffi-devel openssl-devel gcc redhat-rpm-config

python3 --version
which pip3
pip3 --version

pip3 install --upgrade pip

# Avoid bug in default python cryptography library
# [WARNING]: Optional dependency 'cryptography' raised an exception, falling back to 'Crypto'
echo '>>> Upgrading python cryptography library'
pip3 install --upgrade cryptography

echo '>>> Installing Ansible'
pip3 install ansible==2.7.8

echo '>>> Ansible Should be Using Python3'
ansible --version