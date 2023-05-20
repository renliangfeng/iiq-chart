#!/bin/bash
#
# Deploy IIQ Docker image to Kubernte cluster
#

type=ui
if [ ! -z "$1" ]; then
    env=$1
    if [ ! -z "$2" ] && [ $env != "sandbox" ]; then
        type=$2
    fi
    echo "#### Deploy IIQ Docker instance (server type: $type) for env $env. ##### "


    releaseName=iiq

    kubectl create namespace iiq

    helm install $releaseName  . --values ./values.yaml --values env/$env/values.yaml --namespace=iiq

else
    echo "#### Please environment (sandbox, dev, uat or prod) by passing the value in the first parameter"
fi
