# Upgrade notes from 1.11.0 -> 1.11.1

Release Notes: [1.11.1](../release-notes.md)

## Update Helm Repository

```shell
helm repo add iomete https://chartmuseum.iomete.com
helm repo update
```

## Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.11.1
iomete/iom-catalog:1.11.1
iomete/iom-core:1.11.1
iomete/iom-data-plane-init:1.11.1
iomete/iom-identity:1.11.1
iomete/iom-openapi-ui:1.11.1
iomete/iom-socket:1.11.1
iomete/iom-sql:1.11.1
```

## Upgrade IOMETE Data Plane


### Update CRDs from Base Chart

```shell
helm pull iomete/iomete-data-plane-base --untar

kubectl apply -f iomete-data-plane-base/crds
```


### Update Data Plane

Ensure your `data-plane-values.yaml` file is correctly configured before deploying the IOMETE Data Plane:
  - Update `docker.appVersion` to `1.11.1`

```shell
# helm repo update iomete
helm upgrade --install -n iomete-system data-plane \
  iomete/iomete-data-plane-enterprise \
  -f example-data-plane-values.yaml --version 1.11
```

