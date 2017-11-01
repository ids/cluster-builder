Warnings
--------
The following controls are not needed because they affect the operation of UCP/DTR:

2.1 Restrict network traffic between containers — Needed for container communication
2.6 Configure TLS authentication for Docker daemon — Should not be enabled as it is not needed
2.8 Enable user namespace support — Currently not supported with UCP/DTR
2.15 Do not enable Swarm mode, if not needed — Swarm mode is the underlying orchestration framework
2.18 Disable Userland Proxy — Disabling the proxy affects how the routing mesh works

Reference for mitigation:
https://www.nearform.com/blog/securing-docker-containers-on-aws/

[WARN] 1.1  - Ensure a separate partition for containers has been created
This appears in error as /var/lib/docker is no longer relevant with direct-lvm, which already places docker data on a dedicated block device.

[WARN] 1.5  - Ensure auditing is configured for the Docker daemon
[WARN] 1.6  - Ensure auditing is configured for Docker files and directories - /var/lib/docker
[WARN] 1.7  - Ensure auditing is configured for Docker files and directories - /etc/docker
[WARN] 1.8  - Ensure auditing is configured for Docker files and directories - docker.service
[WARN] 1.11 - Ensure auditing is configured for Docker files and directories - /etc/docker/daemon.json
Mitigated in audit.rules

[WARN] 2.1  - Ensure network traffic is restricted between containers on the default bridge
Disregard

[WARN] 2.8  - Enable user namespace support
Disregard

[WARN] 2.11 - Ensure that authorization for Docker client commands is enabled
Disregard

[WARN] 2.12 - Ensure centralized and remote logging is configured
ELK based

[WARN] 2.13 - Ensure operations on legacy registry (v1) are Disabled
Disregard

[WARN] 2.15 - Ensure Userland Proxy is Disabled
Disregard

[WARN] 2.17 - Ensure experimental features are avoided in production
Disregard

[WARN] 4.1  - Ensure a user for the container has been created
[WARN]      * Running as root: portainer.1.p8sqjxr38gh35gub5u0u46d2n
Disregard

[WARN] 4.5  - Ensure Content trust for Docker is Enabled
TODO: Implementation of Notary and DTR

[WARN] 4.6  - Ensure HEALTHCHECK instructions have been added to the container image
[WARN]      * No Healthcheck found: [portainer/portainer:develop]
[WARN]      * No Healthcheck found: [dperson/samba:latest]
[WARN] 5.1  - Ensure AppArmor Profile is Enabled
[WARN]      * No AppArmorProfile Found: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.2  - Ensure SELinux security options are set, if applicable
[WARN]      * No SecurityOptions Found: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.10 - Ensure memory usage for container is limited
[WARN]      * Container running without memory restrictions: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.11 - Ensure CPU priority is set appropriately on the container
[WARN]      * Container running without CPU restrictions: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.12 - Ensure the container's root filesystem is mounted as read only
[WARN]      * Container running with root FS mounted R/W: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.14 - Ensure 'on-failure' container restart policy is set to '5'
[WARN]      * MaximumRetryCount is not set to 5: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.25 - Ensure the container is restricted from acquiring additional privileges
[WARN]      * Privileges not restricted: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.26 - Ensure container health is checked at runtime
[WARN]      * Health check not set: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.28 - Ensure PIDs cgroup limit is used
[WARN]      * PIDs limit not set: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.31 - Ensure the Docker socket is not mounted inside any containers
[WARN]      * Docker socket shared: portainer.1.p8sqjxr38gh35gub5u0u46d2n
Note: Portainer configuration

[WARN] 7.1  - Ensure swarm mode is not Enabled, if not needed
Disregard

[WARN] 7.4  - Ensure data exchanged between containers are encrypted on different nodes on the overlay network
[WARN]      * Unencrypted overlay network: ingress (swarm)
TODO: consider encryption of overlay networks

[WARN] 7.6  - Ensure swarm manager is run in auto-lock mode
Note: This seems dumb and requires a manual step on a constant basis.  Seems like a bad idea.
https://docs.docker.com/engine/swarm/swarm_manager_locking/

# ------------------------------------------------------------------------------
# Docker Bench for Security v1.3.4
#
# Docker, Inc. (c) 2015-
#
# Checks for dozens of common best-practices around deploying Docker containers in production.
# Inspired by the CIS Docker Community Edition Benchmark v1.1.0.
# ------------------------------------------------------------------------------

Initializing Wed Nov  1 17:38:06 GMT 2017

[INFO] 1 - Host Configuration
[WARN] 1.1  - Ensure a separate partition for containers has been created
[NOTE] 1.2  - Ensure the container host has been Hardened
[INFO] 1.3  - Ensure Docker is up to date
[INFO]      * Using 17.09.0, verify is it up to date as deemed necessary
[INFO]      * Your operating system vendor may provide support and security maintenance for Docker
[INFO] 1.4  - Ensure only trusted users are allowed to control Docker daemon
[INFO]      * docker:x:1002:admin,docker
[WARN] 1.5  - Ensure auditing is configured for the Docker daemon
[WARN] 1.6  - Ensure auditing is configured for Docker files and directories - /var/lib/docker
[WARN] 1.7  - Ensure auditing is configured for Docker files and directories - /etc/docker
[WARN] 1.8  - Ensure auditing is configured for Docker files and directories - docker.service
[INFO] 1.9  - Ensure auditing is configured for Docker files and directories - docker.socket
[INFO]      * File not found
[INFO] 1.10 - Ensure auditing is configured for Docker files and directories - /etc/default/docker
[INFO]      * File not found
[WARN] 1.11 - Ensure auditing is configured for Docker files and directories - /etc/docker/daemon.json
[INFO] 1.12 - Ensure auditing is configured for Docker files and directories - /usr/bin/docker-containerd
[INFO]      * File not found
[INFO] 1.13 - Ensure auditing is configured for Docker files and directories - /usr/bin/docker-runc
[INFO]      * File not found


[INFO] 2 - Docker daemon configuration
[WARN] 2.1  - Ensure network traffic is restricted between containers on the default bridge
[PASS] 2.2  - Ensure the logging level is set to 'info'
[PASS] 2.3  - Ensure Docker is allowed to make changes to iptables
[PASS] 2.4  - Ensure insecure registries are not used
[PASS] 2.5  - Ensure aufs storage driver is not used
[PASS] 2.6  - Ensure TLS authentication for Docker daemon is configured
[INFO] 2.7  - Ensure the default ulimit is configured appropriately
[INFO]      * Default ulimit doesn't appear to be set
[WARN] 2.8  - Enable user namespace support
[PASS] 2.9  - Ensure the default cgroup usage has been confirmed
[PASS] 2.10 - Ensure base device size is not changed until needed
[WARN] 2.11 - Ensure that authorization for Docker client commands is enabled
[WARN] 2.12 - Ensure centralized and remote logging is configured
[WARN] 2.13 - Ensure operations on legacy registry (v1) are Disabled
[PASS] 2.14 - Ensure live restore is Enabled (Incompatible with swarm mode)
[WARN] 2.15 - Ensure Userland Proxy is Disabled
[PASS] 2.16 - Ensure daemon-wide custom seccomp profile is applied, if needed
[WARN] 2.17 - Ensure experimental features are avoided in production
[PASS] 2.18 - Ensure containers are restricted from acquiring new privileges


[INFO] 3 - Docker daemon configuration files
[PASS] 3.1  - Ensure that docker.service file ownership is set to root:root
[PASS] 3.2  - Ensure that docker.service file permissions are set to 644 or more restrictive
[INFO] 3.3  - Ensure that docker.socket file ownership is set to root:root
[INFO]      * File not found
[INFO] 3.4  - Ensure that docker.socket file permissions are set to 644 or more restrictive
[INFO]      * File not found
[PASS] 3.5  - Ensure that /etc/docker directory ownership is set to root:root
[PASS] 3.6  - Ensure that /etc/docker directory permissions are set to 755 or more restrictive
[INFO] 3.7  - Ensure that registry certificate file ownership is set to root:root
[INFO]      * Directory not found
[INFO] 3.8  - Ensure that registry certificate file permissions are set to 444 or more restrictive
[INFO]      * Directory not found
[PASS] 3.9  - Ensure that TLS CA certificate file ownership is set to root:root
[PASS] 3.10 - Ensure that TLS CA certificate file permissions are set to 444 or more restrictive
[PASS] 3.11 - Ensure that Docker server certificate file ownership is set to root:root
[PASS] 3.12 - Ensure that Docker server certificate file permissions are set to 444 or more restrictive
[PASS] 3.13 - Ensure that Docker server certificate key file ownership is set to root:root
[PASS] 3.14 - Ensure that Docker server certificate key file permissions are set to 400
[PASS] 3.15 - Ensure that Docker socket file ownership is set to root:docker
[PASS] 3.16 - Ensure that Docker socket file permissions are set to 660 or more restrictive
[PASS] 3.17 - Ensure that daemon.json file ownership is set to root:root
[PASS] 3.18 - Ensure that daemon.json file permissions are set to 644 or more restrictive
[INFO] 3.19 - Ensure that /etc/default/docker file ownership is set to root:root
[INFO]      * File not found
[INFO] 3.20 - Ensure that /etc/default/docker file permissions are set to 644 or more restrictive
[INFO]      * File not found


[INFO] 4 - Container Images and Build File
[WARN] 4.1  - Ensure a user for the container has been created
[WARN]      * Running as root: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[NOTE] 4.2  - Ensure that containers use trusted base images
[NOTE] 4.3  - Ensure unnecessary packages are not installed in the container
[NOTE] 4.4  - Ensure images are scanned and rebuilt to include security patches
[WARN] 4.5  - Ensure Content trust for Docker is Enabled
[WARN] 4.6  - Ensure HEALTHCHECK instructions have been added to the container image
[WARN]      * No Healthcheck found: [portainer/portainer:develop]
[WARN]      * No Healthcheck found: [dperson/samba:latest]
[PASS] 4.7  - Ensure update instructions are not use alone in the Dockerfile
[NOTE] 4.8  - Ensure setuid and setgid permissions are removed in the images
[INFO] 4.9  - Ensure COPY is used instead of ADD in Dockerfile
[INFO]      * ADD in image history: [docker/docker-bench-security:latest]
[INFO]      * ADD in image history: [dperson/samba:latest]
[NOTE] 4.10 - Ensure secrets are not stored in Dockerfiles
[NOTE] 4.11 - Ensure verified packages are only Installed


[INFO] 5 - Container Runtime
[WARN] 5.1  - Ensure AppArmor Profile is Enabled
[WARN]      * No AppArmorProfile Found: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.2  - Ensure SELinux security options are set, if applicable
[WARN]      * No SecurityOptions Found: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[PASS] 5.3  - Ensure Linux Kernel Capabilities are restricted within containers
[PASS] 5.4  - Ensure privileged containers are not used
[PASS] 5.5  - Ensure sensitive host system directories are not mounted on containers
[PASS] 5.6  - Ensure ssh is not run within containers
[PASS] 5.7  - Ensure privileged ports are not mapped within containers
[NOTE] 5.8  - Ensure only needed ports are open on the container
[PASS] 5.9  - Ensure the host's network namespace is not shared
[WARN] 5.10 - Ensure memory usage for container is limited
[WARN]      * Container running without memory restrictions: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.11 - Ensure CPU priority is set appropriately on the container
[WARN]      * Container running without CPU restrictions: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.12 - Ensure the container's root filesystem is mounted as read only
[WARN]      * Container running with root FS mounted R/W: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[PASS] 5.13 -  Ensure incoming container traffic is binded to a specific host interface
[WARN] 5.14 - Ensure 'on-failure' container restart policy is set to '5'
[WARN]      * MaximumRetryCount is not set to 5: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[PASS] 5.15 - Ensure the host's process namespace is not shared
[PASS] 5.16 - Ensure the host's IPC namespace is not shared
[PASS] 5.17 - Ensure host devices are not directly exposed to containers
[INFO] 5.18 - Ensure the default ulimit is overwritten at runtime, only if needed
[INFO]      * Container no default ulimit override: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[PASS] 5.19 - Ensure mount propagation mode is not set to shared
[PASS] 5.20 - Ensure the host's UTS namespace is not shared
[PASS] 5.21 - Ensure the default seccomp profile is not Disabled
[NOTE] 5.22 - Ensure docker exec commands are not used with privileged option
[NOTE] 5.23 - Ensure docker exec commands are not used with user option
[PASS] 5.24 - Ensure cgroup usage is confirmed
[WARN] 5.25 - Ensure the container is restricted from acquiring additional privileges
[WARN]      * Privileges not restricted: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[WARN] 5.26 - Ensure container health is checked at runtime
[WARN]      * Health check not set: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[INFO] 5.27 - Ensure docker commands always get the latest version of the image
[WARN] 5.28 - Ensure PIDs cgroup limit is used
[WARN]      * PIDs limit not set: portainer.1.p8sqjxr38gh35gub5u0u46d2n
[PASS] 5.29 - Ensure Docker's default bridge docker0 is not used
[PASS] 5.30 - Ensure the host's user namespaces is not shared
[WARN] 5.31 - Ensure the Docker socket is not mounted inside any containers
[WARN]      * Docker socket shared: portainer.1.p8sqjxr38gh35gub5u0u46d2n


[INFO] 6 - Docker Security Operations
[INFO] 6.1  - Avoid image sprawl
[INFO]      * There are currently: 3 images
[INFO] 6.2  - Avoid container sprawl
[INFO]      * There are currently a total of 2 containers, with 2 of them currently running


[INFO] 7 - Docker Swarm Configuration
[WARN] 7.1  - Ensure swarm mode is not Enabled, if not needed
[PASS] 7.2  - Ensure the minimum number of manager nodes have been created in a swarm
[PASS] 7.3  - Ensure swarm services are binded to a specific host interface
[WARN] 7.4  - Ensure data exchanged between containers are encrypted on different nodes on the overlay network
[WARN]      * Unencrypted overlay network: ingress (swarm)
[INFO] 7.5  - Ensure Docker's secret management commands are used for managing secrets in a Swarm cluster
[WARN] 7.6  - Ensure swarm manager is run in auto-lock mode
[NOTE] 7.7  - Ensure swarm manager auto-lock key is rotated periodically
[INFO] 7.8  - Ensure node certificates are rotated as appropriate
[INFO] 7.9  - Ensure CA certificates are rotated as appropriate
[INFO] 7.10 - Ensure management plane traffic has been separated from data plane traffic