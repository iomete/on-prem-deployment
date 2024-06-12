# Upgrade notes from 1.13.2 -> 1.13.3

Release Notes: [1.13.3](../release-notes.md)


## Updated Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.13.3
iomete/iom-catalog:1.13.3
iomete/iom-core:1.13.3
iomete/iom-data-plane-init:1.13.3
iomete/iom-identity:1.13.3
iomete/iom-sql:1.13.3
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
  -f example-data-plane-values.yaml --version 1.13
```

Notes:
- Manually restart `iom-identity` service after deployment completed.

