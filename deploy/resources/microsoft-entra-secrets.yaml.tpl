apiVersion: v1
kind: Secret
metadata:
  name: microsoft-entra-secrets
type: Opaque
stringData:
  AZURE_TENANT_ID: ${AZURE_TENANT_ID}
  AZURE_CLIENT_ID: ${AZURE_CLIENT_ID}
  AZURE_CLIENT_SECRET: ${AZURE_CLIENT_SECRET}