apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-rhdh-config
data:
  bs_app_name: ${bs_app_name}
  openshift_ingress_domain: ${openshift_ingress_domain}
  registry_hostname: ${registry_hostname}