#!/usr/bin/env bash
DOCKER_VERSION=17.09.0-ce

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
echo "***   - Upgrade Docker to ${DOCKER_VERSION}"
echo "***"

tdnf -y install open-vm-tools nfs-utils tar gzip curl ntp python2

echo "*** Downloading Docker ${DOCKER_VERSION}"
curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz 
echo "*** Unpacking Docker ${DOCKER_VERSION}"
tar --strip-components=1 -C /usr/bin -xzf docker-${DOCKER_VERSION}.tgz 

echo "*** Configuring Docker ${DOCKER_VERSION}"
echo '[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
EnvironmentFile=-/etc/default/docker
ExecStart=/usr/bin/dockerd $DOCKER_OPTS
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
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