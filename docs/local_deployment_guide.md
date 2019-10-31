## Cluster Builder - VMware Local Deployment Guide

VMware local deployment is geared toward building small clusters on a laptop for demo purposes.  Deployments are made to local machines running:

* VMware Fusion Pro 10+ on macOS
* VMware Workstation Pro 12+ on Windows
* VMware Workstation Pro 12+ on Linux

> **Note:** DC/OS requires at least 16GB of ram on the target machine.

---
### Notes

* The VMware Fusion application should be running on macOS.

* The VMware tools need to be in the PATH

* The hostnames used in the cluster definition packages must resolve via DNS or be statically set in `/etc/hosts`

#### VMware Tools Path

Ensure the VMware CLI tools are setup in the BASH PATH:

Eg for macOS.

		export VM_TOOLS="/Library/Application Support/VMware Fusion"
		export PATH=$PATH:/usr/local/bin:/usr/bin:~/bin:$VM_TOOLS

		if [ -d "/Applications/VMware Fusion.app/Contents/Library" ]; then
		export PATH=$PATH:"/Applications/VMware Fusion.app/Contents/Library"
		fi

		if [ -d "/Applications/VMware OVF Tool/" ]; then
		export PATH=$PATH:"/Applications/VMware OVF Tool/"
		fi

#### Host /etc/hosts

The hostnames of the target VM nodes used in the cluster definition package:

		192.168.100.90  demo-k8k8ss-m1  drupal.idstudios.vmware
		192.168.100.91	demo-k8s-w1
		192.168.100.92	demo-k8s-w2
		192.168.100.93	demo-k8s-w3

> The preferred approach is to use a DNS server.

---

> The script requires an active local sudo session as the VMware network controls require sudo, but this is difficult to prompt for with ansible.  If you don't have one, the script will prompt you for your local SUDO machine password.

The ansible scripts will adjust your local VMware network dhcpd.conf file based on the MAC addresses assigned during creation of the VMs, and the static IPs will be assigned by VMware via MAC address.

Once the VMs have been created, assigned their correct addresses, and are running, cluster provisioning process will begin.

> __Note__ that all settings marked as __desktop__ apply to all of the VMware desktop platforms.

### Ansible Fusion Configuration

### Fusion Sample: demo-centos-k8s hosts file

```
[all:vars]
cluster_type=centos-k8s
cluster_name=k8s-demo
remote_user=admin

vmware_target=desktop
desktop_vm_folder="../virtuals"

desktop_net="vmnet2"         # this should be vmnet8 for Windows and Linux
desktop_net_type="custom"    # this should be nat for Windows and Linux

network_mask=255.255.255.0
network_gateway=192.168.100.1
network_dns=8.8.8.8
network_dns2=8.8.4.4
network_dn=demo.idstudios.io

targetd_server=192.168.100.250
targetd_server_iqn=iqn.2003-01.org.linux-iscsi.minishift:targetd
targetd_server_volume_group=vg-targetd
targetd_server_provisioner_name=iscsi-targetd
targetd_server_account_credentials=targetd-account
targetd_server_account_username=admin
targetd_server_account_password=ciao

k8s_version=1.14.*
k8s_metallb_address_range=192.168.100.150-192.168.100.169
k8s_network_cni=canal
k8s_control_plane_uri=k8s-admin-single.demo.idstudios.io
k8s_ingress_url=k8s-ingress.demo.idstudios.io
k8s_cluster_token=9aeb42.99b7540a5833866a

[k8s_masters]
k8s-m1.demo.idstudios.io ansible_host=192.168.100.200 

[k8s_workers]
k8s-w1.demo.idstudios.io ansible_host=192.168.100.201
k8s-w2.demo.idstudios.io ansible_host=192.168.100.202
k8s-w3.demo.idstudios.io ansible_host=192.168.100.203

[vmware_vms]
k8s-m1.demo.idstudios.io numvcpus=4 memsize=2048
k8s-w1.demo.idstudios.io numvcpus=4 memsize=3072
k8s-w2.demo.idstudios.io numvcpus=4 memsize=3072
k8s-w3.demo.idstudios.io numvcpus=4 memsize=3072
```

**cluster_type**: one of _centos-dcos_, _centos-k8s or _fedora-k8s_.

**vmware_target**: _desktop_ (also applies for workstation)

**desktop_net**: The name of the VMware network, vmnet[1-n], default is **vmnet2** with a network of 192.168.100.0.

**desktop_net_type**: One of _nat_, _bridged_ or _custom_.

__network_dns__: DNS entry for the primary interface

__network_dns2__: 2nd DNS entry for the primary interface

__network_dns3__: 3rd DNS entry for the primary interface

__network_dn__: Domain name for the primary interface subnet

__docker_daemon_dns_override__: (optional)  By default, cluster-builder will use the dns entries defined for the host interfaces (network_dns, network_dns2, etc).  If a different DNS configuration is desired for Docker, this value can be used to override the default behavior.  It must be supplied in the JSON string array form:

		docker_daemon_dns_override='"192.168.1.1", "8.8.8.8"'

> Note the single quotes wrapping the double quotes.
