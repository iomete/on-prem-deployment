# Upgrade notes from 1.13.1 -> 1.13.2

Release Notes: [1.13.2](../release-notes.md)

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

