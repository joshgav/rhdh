#! /usr/bin/env bash

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/.. && pwd)
workspace_dir=$(cd ${root_dir}/.. && pwd)
if [[ -e "${root_dir}/.env" ]]; then source ${root_dir}/.env; fi
if [[ -e "${this_dir}/.env" ]]; then source ${this_dir}/.env; fi
source ${root_dir}/lib/kubernetes.sh

export bs_app_name=${1:-${BS_APP_NAME:-rhdh}}
export quay_user_name=${2:-${QUAY_USER_NAME:-joshgav}}
export openshift_ingress_domain=$(oc get ingresses.config.openshift.io cluster -ojson | jq -r .spec.domain)
export registry_hostname=${REGISTRY_HOSTNAME:-quay.aws.joshgav.com}
export upstream_image_url=quay.io/rhdh/rhdh-hub-rhel9:next

ensure_namespace ${bs_app_name} true
apply_kustomize_dir ${this_dir}/resources

echo "INFO: Visit your Backstage instance at https://backstage-backstage-${bs_app_name}.${openshift_ingress_domain}/"
