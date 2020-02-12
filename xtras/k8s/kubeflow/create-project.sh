#!/usr/bin/env bash

export KFAPP=kf-main 
if [ "$1" != "" ]; then 
  KFAPP=$1
fi 

# Installs Istio by default. Comment out Istio components in the config file to skip Istio installation. See https://github.com/kubeflow/kubeflow/pull/3663
export CONFIG="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_k8s_istio.yaml"

mkdir -p ${KFAPP}
cd ${KFAPP}
kfctl apply -V -f ${CONFIG}
