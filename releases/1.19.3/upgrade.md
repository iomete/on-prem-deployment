# Upgrade notes for 1.19.3

Release Notes: [1.19.3](../release-notes.md)


## Updated Docker images

No docker images are updated in this release.

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
  -f example-data-plane-values.yaml --version 1.19.3
```
