#echo '>>> Configure netplan for mac address usage'
#cat > /etc/netplan/01-netcfg.yaml << EOF

#network:
#  version: 2
#  renderer: networkd 
#  ethernets:
#    ens32:
#      dhcp4: yes
#      dhcp-identifier: mac
#EOF

#chmod 644 /etc/netplan/01-netcfg.yaml
#netplan apply

#truncate -s 0 /etc/machine-id
