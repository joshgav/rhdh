apiVersion: v1
kind: Secret
metadata:
  name: kubernetes-token
type: Opaque
stringData:
  K8S_SERVICEACCOUNT_TOKEN: ${K8S_SERVICEACCOUNT_TOKEN}