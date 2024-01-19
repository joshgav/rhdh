#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
workspace_dir=$(cd ${root_dir}/.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${this_dir}/lib/kubernetes.sh

export bs_app_name=${1:-${BS_APP_NAME:-rhdh3}}
export quay_user_name=${2:-${QUAY_USER_NAME:-joshgav}}
export openshift_ingress_domain=$(oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain)
export upstream_image_url=quay.io/rhdh/rhdh-hub-rhel9:1.1

export registry_hostname=${REGISTRY_HOSTNAME:-quay.io}
export image_url_path=${quay_user_name}/${bs_app_name}-backstage
export image_tag=latest
export image_url_full=${registry_hostname}/${image_url_path}:${image_tag}

ensure_namespace ${bs_app_name} true

if [[ "${COPY_IMAGE}" == "1" ]]; then
    skopeo copy docker://${upstream_image_url} docker://${image_url_full}
fi

echo "INFO: apply resources from ${this_dir}/resources/*.yaml"
for file in $(ls ${this_dir}/resources/*.yaml); do
    cat ${file} | envsubst '${ARGOCD_AUTH_TOKEN}
                            ${QUAY_TOKEN}
                            ${GITHUB_TOKEN}
                            ${GITHUB_APP_CLIENT_ID}
                            ${GITHUB_APP_CLIENT_SECRET}' | kubectl apply -f -
done

## apply custom app-config-rhdh.yaml from this dir
file_path=${this_dir}/app-config-rhdh.yaml
if [[ -e "${file_path}" ]]; then
    echo "INFO: applying appconfig configmap from ${file_path}"
    kubectl delete configmap app-config-rhdh 2> /dev/null

    tmpfile=$(mktemp)
    cat "${file_path}" | envsubst '${bs_app_name}
                                   ${quay_user_name}
                                   ${openshift_ingress_domain}
                                   ${registry_hostname}' > ${tmpfile}
    kubectl create configmap app-config-rhdh \
        --from-file "$(basename ${file_path})=${tmpfile}"
else
    echo "INFO: no file found at ${file_path}"
fi

github_app_creds_path=${this_dir}/github-app-credentials.yaml
if [[ -n "${GITHUB_APP_ID}" ]]; then
    echo "INFO: using env vars for GITHUB_APP metadata"
    cat ${this_dir}/github-app-credentials.yaml.tpl | \
        envsubst '
            ${GITHUB_APP_ID}
            ${GITHUB_APP_CLIENT_ID}
            ${GITHUB_APP_CLIENT_SECRET}
            ${GITHUB_APP_WEBHOOK_URL}
            ${GITHUB_APP_WEBHOOK_SECRET}
            ${GITHUB_APP_PRIVATE_KEY}
        ' > ${github_app_creds_path}
    kubectl delete secret github-app-credentials 2> /dev/null
    kubectl create secret generic github-app-credentials --from-file=${github_app_creds_path}
fi

oc get clusterrolebinding ${bs_app_name}-backend-k8s &> /dev/null
if [[ $? != 0 ]]; then
    oc create clusterrolebinding ${bs_app_name}-backend-k8s --clusterrole=backstage-k8s-plugin --serviceaccount=${bs_app_name}:default
fi
oc get clusterrolebinding ${bs_app_name}-backend-tekton &> /dev/null
if [[ $? != 0 ]]; then
    oc create clusterrolebinding ${bs_app_name}-backend-tekton --clusterrole=backstage-tekton-plugin --serviceaccount=${bs_app_name}:default
fi

echo "INFO: helm upgrade --install"
ensure_helm_repo bitnami https://charts.bitnami.com/bitnami 1> /dev/null
ensure_helm_repo backstage https://backstage.github.io/charts 1> /dev/null
ensure_helm_repo redhat https://charts.openshift.io/ 1> /dev/null

for file in $(ls ${this_dir}/chart-values/*.yaml.tpl); do
    cat "${file}" | envsubst '${bs_app_name} ${quay_user_name} ${openshift_ingress_domain} ${registry_hostname} ${image_url_path} ${image_tag}' > ${file%".tpl"}
    chart_values+=" --values ${file%.tpl}"
done

echo "INFO: using chart values flags: ${chart_values}"
helm upgrade --install ${bs_app_name} redhat/redhat-developer-hub ${chart_values}
# oc rollout restart deployment ${bs_app_name}-developer-hub

# echo "INFO: Visit your Backstage instance at https://backstage-${bs_app_name}.${openshift_ingress_domain}/"
