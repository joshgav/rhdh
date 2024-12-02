#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
workspace_dir=$(cd ${root_dir}/.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${this_dir}/lib/kubernetes.sh

AZURE_GROUP_NAME=aks1-devhub
AZURE_REGION=eastus
AZURE_AKS_NAME=aks1-devhub

az group create --name ${AZURE_GROUP_NAME} --location ${AZURE_REGION}
az aks create \
    --resource-group ${AZURE_GROUP_NAME} \
    --name ${AZURE_AKS_NAME} \
    --enable-managed-identity \
    --generate-ssh-keys

# az extension add --upgrade -n aks-preview --allow-preview true
az aks approuting enable --resource-group ${AZURE_GROUP_NAME} --name ${AZURE_AKS_NAME}
az aks get-credentials --resource-group ${AZURE_GROUP_NAME} --name ${AZURE_AKS_NAME}

kubectl get svc nginx --namespace app-routing-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# add A record for hostname

RHDH_DEPLOYMENT_NAME=rhdh
RHDH_NAMESPACE=rhdh
kubectl create namespace ${RHDH_NAMESPACE}
kubectl config set-context --current --namespace=${RHDH_NAMESPACE}

# https://access.redhat.com/terms-based-registry/
kubectl -n ${RHDH_NAMESPACE} create secret docker-registry rhdh-pull-secret \
    --docker-server=registry.redhat.io \
    --docker-username=${REDHAT_REGISTRY_USERNAME} \
    --docker-password=${REDHAT_REGISTRY_PASSWORD} \
    --docker-email=${REDHAT_REGISTRY_EMAIL}

helm repo add openshift-helm-charts https://charts.openshift.io/
helm repo update

helm -n ${RHDH_NAMESPACE} install ${RHDH_DEPLOYMENT_NAME} openshift-helm-charts/redhat-developer-hub \
    --version 1.3.0 \
    -f ${this_dir}/resources/values.yaml

kubectl get deployment ${RHDH_DEPLOYMENT_NAME}-developer-hub -n ${RHDH_NAMESPACE}
