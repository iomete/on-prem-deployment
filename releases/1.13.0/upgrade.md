# Upgrade notes from 1.12 -> 1.13.0

Release Notes: [1.13.0](../release-notes.md)

## Update Helm Repository

```shell
helm repo add iomete https://chartmuseum.iomete.com
helm repo update
```

## Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.13.0
iomete/iom-catalog:1.13.0
iomete/iom-core:1.13.0
iomete/iom-data-plane-init:1.13.0
iomete/iom-identity:1.13.0
iomete/iom-sql:1.13.0

iomete/iom-catalog-sync:1.10.0
```

## Upgrade IOMETE Data Plane Base

Added `events` role to the lakehouse service account.  

```yaml
- verbs:
    - get
    - list
    - watch
  apiGroups:
    - events.k8s.io
  resources:
    - events
```

You need to upgrade the `iomete-data-plane-base` chart to `1.13.0` version.

```shell
helm upgrade --install -n iomete-system data-plane-base \
  iomete/iomete-data-plane-base --version 1.13
```
Note: Provide data-plane-values.yaml file if you have custom values.  


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

