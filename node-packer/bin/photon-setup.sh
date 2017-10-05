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

tdnf -y install open-vm-tools nfs-utils tar gzip curl ntp

echo "*** Downloading Docker ${DOCKER_VERSION}"
curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz 
echo "*** Unpacking Docker ${DOCKER_VERSION}"
tar --strip-components=1 -C /usr/bin -xzf docker-${DOCKER_VERSION}.tgz 

echo "*** Configuring Docker ${DOCKER_VERSION}"
echo '[Unit]
Description=Docker Daemon
Documentation=http://docs.docker.com
Wants=network-online.target
After=network-online.target docker-containerd.service
Requires=docker-containerd.service

[Service]
Type=notify
EnvironmentFile=-/etc/default/docker
ExecStart=/usr/bin/dockerd $DOCKER_OPTS \
          --containerd /run/containerd.sock
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-abnormal
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
' > /usr/lib/systemd/system/docker.service

systemctl daemon-reload
systemctl enable docker
systemctl start docker

echo "*** Clearing the DHCP uuid used by Photon"
echo -n > /etc/machine-id