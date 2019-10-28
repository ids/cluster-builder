#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo '>>> Installing base dependencies'
apt-get -y install python3.6 python3-dev libssl-dev gcc open-vm-tools ansible
