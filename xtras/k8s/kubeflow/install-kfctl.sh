#!/usr/bin/env bash

opsys=$1 # darwin for Mac, linux for everything else
    
curl -s https://api.github.com/repos/kubeflow/kubeflow/releases/latest |\
    grep browser_download | \
    grep $opsys | \
    cut -d '"' -f 4 | \
    xargs curl -O -L && \
    tar -zvxf kfctl_*_${opsys}.tar.gz

sudo mv kfctl /usr/local/bin
rm kfctl_*_${opsys}.tar.gz
echo "Moved kfctl to /usr/local/bin, make sure it is in the PATH"
