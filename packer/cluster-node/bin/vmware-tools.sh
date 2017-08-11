#!/usr/bin/env bash

echo '***'
echo '*** Installing VMware Tools'
echo '***'

sudo yum -y install open-vm-tools

#sudo mount /home/admin/linux.iso /mnt
#ls /mnt
#cp /mnt/VMwareTools-*.gz /tmp
#cd /tmp
#tar zxvf VMwareTools-*.gz
#vmware-tools-distrib/vmware-install.pl -d
#rm -rf VMwareTools-*
#rm -rf vmware-tools-distrib
#sudo umount /mnt
#sudo rm /home/admin/linux.iso
