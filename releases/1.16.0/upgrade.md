# Upgrade notes for 1.16.0

Release Notes: [1.16.0](../release-notes.md)


## Updated Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.16.0
iomete/iom-catalog:1.16.0
iomete/iom-core:1.16.0
iomete/iom-data-plane-init:1.16.0
iomete/iom-identity:1.16.0
iomete/iom-sql:1.16.0

iomete/spark-operator:3.5.1-v2

iomete/spark:3.5.1-v1
iomete/spark-py:3.5.1-v1

iomete/iom-connect-rest-client:1.1.0
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
  -f example-data-plane-values.yaml --version 1.16
```

Notes:
- Manually restart `iom-identity` service after deployment completed.
- Manually restart `iom-spark-connect-driver` pod by deleting it after deployment completed.

