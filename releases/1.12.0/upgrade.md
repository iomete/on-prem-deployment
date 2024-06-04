# Upgrade notes from 1.11 -> 1.12.0

Release Notes: [1.12.0](../release-notes.md)

## Update Helm Repository

```shell
helm repo add iomete https://chartmuseum.iomete.com
helm repo update
```

## Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.12.0
iomete/iom-catalog:1.12.0
iomete/iom-core:1.12.0
iomete/iom-data-plane-init:1.12.0
iomete/iom-identity:1.12.0
iomete/iom-openapi-ui:1.10.0
iomete/iom-socket:1.10.0
iomete/iom-sql:1.12.0
# Re-pull images
iomete/spark:3.5.1
iomete/spark-py:3.5.1
```

## Upgrade IOMETE Data Plane

### Update Data Plane

Ensure your `data-plane-values.yaml` file is correctly configured before deploying the IOMETE Data Plane:
  - Update `docker.appVersion` to `1.12.0`

```shell
# helm repo update iomete
helm upgrade --install -n iomete-system data-plane \
  iomete/iomete-data-plane-enterprise \
  -f example-data-plane-values.yaml --version 1.12
```

Notes:
- Restart Spark resources (Lakehouse, Spark Connect) after enabling or disabling audit feature.  

