#!/usr/bin/env bash
DOCKER_VERSION=17.12.0-ce

echo "***"
echo "*** Setting up authorized keys..."
echo "***"

if [ ! -d /root/.ssh ]; then 
  mkdir /root/.ssh
  chmod 700 /root/.ssh
fi 
cp /tmp/authorized_keys /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "***"
echo "*** Installing:"
echo "***   - VMware Tools"
echo "***   - NFS Support"
echo "***   - PIP & Ansible"
echo "***   - Upgrade Docker to ${DOCKER_VERSION}"
echo "***"

tdnf -y install open-vm-tools nfs-utils tar gzip curl ntp python2 python-pip

echo "*** Downloading Docker ${DOCKER_VERSION}"
curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz 
echo "*** Unpacking Docker ${DOCKER_VERSION}"
tar --strip-components=1 -C /usr/bin -xzf docker-${DOCKER_VERSION}.tgz 

echo "*** Configuring Docker ${DOCKER_VERSION}"
echo '[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd 
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
# restart the docker process if it exits prematurely
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
' > /usr/lib/systemd/system/docker.service

systemctl daemon-reload
systemctl enable docker
systemctl start docker

echo "*** Clearing the DHCP uuid used by Photon"
echo -n > /etc/machine-id

#echo '*** Upgrading pip'
pip install --upgrade pip

# Avoid bug in default python cryptography library
# [WARNING]: Optional dependency 'cryptography' raised an exception, falling back to 'Crypto'
echo '*** Upgrading python cryptography library'
pip install --upgrade cryptography

echo '*** Installing Ansible'
pip install ansible==2.4.1
