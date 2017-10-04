#!/usr/bin/env bash

echo '***'
echo '*** Setting up authorized keys...'
echo '***'

if [ ! -d /home/admin/.ssh ]; then 
  mkdir /home/admin/.ssh
  chmod 700 /home/admin/.ssh
fi 
cp /tmp/authorized_keys /home/admin/.ssh/authorized_keys
chmod 600 /home/admin/.ssh/authorized_keys
chown admin:admin -R /home/admin/.ssh
