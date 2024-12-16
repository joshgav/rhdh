## Deploy via Helm

Preliminary commands are in `./deploy.sh`.

## Resources
- Chart: https://github.com/redhat-developer/rhdh-chart
- Docs: https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.3/html/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service/proc-rhdh-deploy-aks-helm_title-install-rhdh-aks
- use: `az aks get-credentials --resource-group ${AZURE_GROUP_NAME} --name ${AZURE_AKS_NAME} \
    --overwrite-existing`
