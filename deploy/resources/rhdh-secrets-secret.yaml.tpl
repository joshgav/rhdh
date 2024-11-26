apiVersion: v1
kind: Secret
metadata:
  name: rhdh-secrets
type: Opaque
stringData:
  BACKEND_SECRET: ${BACKEND_SECRET}
