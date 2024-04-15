# Deploy Monitoring Infrastructure

## 1. Add prometheus-community helm repo

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```


## 2. Deploy kube-prometheus-stack

```shell
helm upgrade -n iomete-system --install --values kube-prometheus-stack/values.yaml prometheus prometheus-community/kube-prometheus-stack --version 51.10.0

# Get grafana admin password
kubectl get secret -n iomete-system prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```