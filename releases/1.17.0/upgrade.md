# Upgrade notes for 1.17.0

Release Notes: [1.17.0](../release-notes.md)


## Updated Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.17.0
iomete/iom-catalog:1.17.0
iomete/iom-core:1.17.0
iomete/iom-data-plane-init:1.17.0
iomete/iom-identity:1.17.0
iomete/iom-sql:1.17.0

iomete/iom-connect-rest-client:1.2.0
```

## Update Helm Repository

```shell
helm repo add iomete https://chartmuseum.iomete.com
helm repo update iomete
```

## Upgrade IOMETE Data Plane

Ensure your `data-plane-values.yaml` file is correctly configured before deploying the IOMETE Data Plane:

Check the spark version in data-plane-values.yaml: `sparkVersion: 3.5.1-v1`

```shell
# helm repo update iomete
helm upgrade --install -n iomete-system data-plane \
  iomete/iomete-data-plane-enterprise \
  -f example-data-plane-values.yaml --version 1.17.0
```

After deployment completed:
Delete pod `iom-spark-connect-driver` manually and wait 20-30 seconds before it will be recreated.
