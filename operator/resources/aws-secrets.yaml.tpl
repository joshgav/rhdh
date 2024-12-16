apiVersion: v1
kind: Secret
metadata:
  name: aws-secrets
type: Opaque
stringData:
  AWS_ACCOUNT_ID: "${AWS_ACCOUNT_ID}"
  AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
  AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"