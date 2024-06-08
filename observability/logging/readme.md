# Deploy Logging Infrastructure

Reference:
- https://hackernoon.com/grafana-loki-architecture-summary-and-running-in-kubernetes

## 1. Add grafana helm repo

```shell
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```


## 2. Deploy Loki

In the `values-on-premises.yaml` file, set the following values:

1. Under `loki.storage.bucketNames`
2. Under `loki.storage.s3` provide the credentials for the S3 bucket where the logs will be stored.


```shell
# if iomete namespace is different, replace iomete-system with the correct namespace
helm upgrade -n iomete-system --install --values loki/values-on-premises.yaml loki grafana/loki --version 6.6.2
```

## 3. Deploy Promtail

```shell
# if iomete namespace is different, replace iomete-system with the correct namespace
helm upgrade -n iomete-system --install --values promtail/values-on-premises.yaml promtail grafana/promtail --version 6.15.5
```