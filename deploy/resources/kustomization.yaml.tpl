apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${bs_app_name}
resources:
- backstage.yaml
- app-config-rhdh.yaml
- custom-rhdh-dynamic-plugins.yaml
- custom-rhdh-config-cm.yaml
- rhdh-secrets-secret.yaml
- github-secrets-secret.yaml
- argocd-token-secret.yaml
- quay-token-secret.yaml
- microsoft-entra-secrets.yaml
- aws-secrets.yaml
- k8s-token-secret.yaml
- default-clusterrolebinding.yaml
