#!/bin/bash

echo "Copy authorized_keys to admin home..."
sudo mkdir -p /home/admin/.ssh
sudo chmod 700 /home/admin/.ssh
sudo chown admin:admin /home/admin/.ssh
sudo cp /tmp/authorized_keys /home/admin/.ssh
sudo chmod 600 /home/admin/.ssh/authorized_keys
sudo chown admin:admin /home/admin/.ssh/authorized_keys

echo "Update the system..."
sudo dnf -y update

echo "Install utility packages..."
sudo dnf -y install mlocate net-tools unzip wget sudo tar xz curl bind-utils sed

echo "Install base dependencies..."
sudo dnf install -y python3 python3-devel python3-pip libffi-devel openssl-devel gcc 

echo "Install iscsiadm..."
sudo dnf install -y iscsi-initiator-utils

echo "Install ansible..."
sudo dnf -y install epel-release
sudo dnf -y install ansible

echo 'Configure Network'
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo '>>> Reload Sysctl'
sudo sysctl --system

echo "Install [containerd]..."
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf makecache
sudo dnf install -y containerd.io
sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.bak
sudo containerd config default > config.toml
sudo mv config.toml /etc/containerd/
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl enable --now containerd.service
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux
sudo sestatus

echo "Configuring Modules..."
sudo tee /etc/modules-load.d/k8s.conf<<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "Disable Swap..."
sudo swapoff -a
sudo sed -e '/swap/s/^/#/g' -i /etc/fstab

echo "Setup K8s Repo..."
sudo tee /etc/yum.repos.d/k8s.repo<<EOF
[kubernetes] 
name=Kubernetes 
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/ 
enabled=1 
gpgcheck=1 
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key 
EOF

echo "Install Kubernetes Binaries..."
sudo dnf makecache
sudo dnf install -y {kubelet,kubeadm,kubectl} --disableexcludes=kubernetes
#sudo yum -y install kubeadm kubelet kubectl

echo "Install Helm..."
#sudo dnf install -y helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "Delete the files ks.cfg..."
sudo rm -f /root/anaconda-ks.cfg /root/original-ks.cfg

echo "Clean dnf cache..."
sudo dnf -y clean all 

echo "Delete temporary files..."
sudo rm -fr /tmp/*
