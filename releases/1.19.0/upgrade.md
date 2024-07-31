# Upgrade notes for 1.19.0

Release Notes: [1.19.0](../release-notes.md)


## Updated Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.19.0
iomete/iom-catalog:1.19.0
iomete/iom-core:1.19.0
iomete/iom-data-plane-init:1.19.0
iomete/iom-identity:1.19.0
iomete/iom-sql:1.19.0
```

## Update Helm Repository

```shell
helm repo add iomete https://chartmuseum.iomete.com
helm repo update iomete
```

## Upgrade IOMETE Data Plane

Ensure your `data-plane-values.yaml` file is correctly configured before deploying the IOMETE Data Plane:

```shell
helm repo update iomete

helm upgrade --install -n iomete-system data-plane \
  iomete/iomete-data-plane-enterprise \
  -f example-data-plane-values.yaml --version 1.19.0
```

Note:
In case if there will be issues on the Console's ui styling, please do a hard refresh (in Chrome / Windows, press `Ctrl + Shift + R`). This will clear the cache.
