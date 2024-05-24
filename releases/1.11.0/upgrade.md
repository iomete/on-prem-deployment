# Upgrade notes from 1.10.0 -> 1.11.0

Release Notes: [1.11.0](../release-notes.md)

## Update Helm Repository

```shell
helm repo add iomete https://chartmuseum.iomete.com
helm repo update
```

## Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.11.0
iomete/iom-catalog:1.11.0
iomete/iom-core:1.11.0
iomete/iom-data-plane-init:1.11.0
iomete/iom-identity:1.11.0
iomete/iom-openapi-ui:1.11.0
iomete/iom-socket:1.11.0
iomete/iom-sql:1.11.0
iomete/metastore:6.3.1
iomete/ranger:2.4.2
iomete/spark:3.5.1
iomete/iom-catalog-sync:1.9.0
```

## Upgrade IOMETE Data Plane

### Helm Values Changes

New configuration:
- `dataCatalog.piiDetection`

See the [IOMETE Data Plane Base Helm Chart](../../helm/iomete-data-plane-base/readme.md) for more details. 


### Upgrade

Ensure your `data-plane-values.yaml` file is correctly configured before deploying the IOMETE Data Plane:

```shell
# helm repo update iomete
helm upgrade --install -n iomete-system data-plane \
  iomete/iomete-data-plane-enterprise \
  -f example-data-plane-values.yaml --version 1.11
```

