WSL Setup Notes
===============

* Install the default ansible via apt-get
* Install kubectl with install-kubectl
* Install docker-ce on Windows WSL with install-docker-wsl script
* Ensure to start the Bash shell with "Run as Administrator"
* Install Packer for Windows
* Install VMware Workstation
* Configure VMnet8 with correct subnet and DHCP settings
* Ensure all VMware tools and Packer are in PATH
  * vmrun.exe
  * ovftool.exe
* Ensure that the hosts configuration uses vmnet8 and nat for the fusion_net settings.


Unlike Fusion where the host-only network is NAT'd by default, host-only on VMware Workstation does not have internet access.  Therefore it is best to use the NAT'd interface, which is  VMnet8 by default.


