WSL Setup Notes
===============

* Install the default ansible via apt-get
* Ensure to start the Bash shell with "Run as Administrator"
* Install Packer for Windows
* Install VMware Workstation
* Configure VMnet8 with correct subnet and DHCP settings
* Ensure all VMware tools and Packer are in PATH
  * vmrun.exe
  * ovftool.exe


Unlike Fusion where the host-only network is NAT'd by default, host-only on VMware Workstation does not have internet access.  Therefore it is best to use the NAT'd interface, which is  VMnet8 by default.


