# Upgrade notes for 1.15.0

Release Notes: [1.15.0](../release-notes.md)


## Updated Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.15.0
iomete/iom-catalog:1.15.0
iomete/iom-core:1.15.0
iomete/iom-data-plane-init:1.15.0
iomete/iom-identity:1.15.0
iomete/iom-sql:1.15.0
iomete/spark-operator:3.5.1-v1

# New image from 1.14.0 version
iomete/iom-connect-rest-client:1.0.0
```

## Update Helm Repository

```shell
helm repo add iomete https://chartmuseum.iomete.com
helm repo update
```

## Upgrade IOMETE Data Plane

Ensure your `data-plane-values.yaml` file is correctly configured before deploying the IOMETE Data Plane:

```shell
# helm repo update iomete
helm upgrade --install -n iomete-system data-plane \
  iomete/iomete-data-plane-enterprise \
  -f example-data-plane-values.yaml --version 1.15
```
