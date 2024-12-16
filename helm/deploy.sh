#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
workspace_dir=$(cd ${root_dir}/.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

render_yaml ${this_dir}/resources

az group show -n ${AZURE_GROUP_NAME} &> /dev/null
if [[ $! == 0 ]]; then
    az group create --name ${AZURE_GROUP_NAME} --location ${AZURE_REGION}
fi

az aks show -n ${AZURE_AKS_NAME} -g ${AZURE_GROUP_NAME} &> /dev/null
if [[ $? != 0 ]]; then
    az aks create \
        --resource-group ${AZURE_GROUP_NAME} \
        --name ${AZURE_AKS_NAME} \
        --enable-managed-identity \
        --generate-ssh-keys
fi

# az extension add --upgrade -n aks-preview --allow-preview true
az aks approuting enable --resource-group ${AZURE_GROUP_NAME} --name ${AZURE_AKS_NAME}
az aks get-credentials --resource-group ${AZURE_GROUP_NAME} --name ${AZURE_AKS_NAME} \
    --overwrite-existing

EXTERNAL_IP_ADDRESS=$(kubectl get svc nginx --namespace app-routing-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "[INFO]: Add a DNS record for ${EXTERNAL_IP_ADDRESS}"
# add A record for hostname

kubectl create namespace ${RHDH_NAMESPACE}
kubectl config set-context --current --namespace=${RHDH_NAMESPACE}

# https://access.redhat.com/terms-based-registry/
kubectl -n ${RHDH_NAMESPACE} create secret docker-registry rhdh-pull-secret \
    --docker-server=registry.redhat.io \
    --docker-username=${REDHAT_REGISTRY_USERNAME} \
    --docker-password=${REDHAT_REGISTRY_PASSWORD} \
    --docker-email=${REDHAT_REGISTRY_EMAIL}

kubectl -n ${RHDH_NAMESPACE} apply -f ${this_dir}/resources/github-secrets-secret.yaml
kubectl -n ${RHDH_NAMESPACE} apply -f ${this_dir}/resources/microsoft-entra-secrets.yaml

helm repo add openshift-helm-charts https://charts.openshift.io/
helm repo update

helm upgrade -i ${RHDH_DEPLOYMENT_NAME} openshift-helm-charts/redhat-developer-hub \
    -n ${RHDH_NAMESPACE} \
    --version 1.3.1 \
    -f ${this_dir}/resources/values.rhdh.yaml \
    -f ${this_dir}/resources/values.dynamic-plugins.yaml \
    -f ${this_dir}/resources/values.app-config.yaml
