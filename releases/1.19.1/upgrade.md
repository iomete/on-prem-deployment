# Upgrade notes for 1.19.1

Release Notes: [1.19.1](../release-notes.md)


## Updated Docker images

Here are list of docker images that have been updated:

```shell
iomete/iom-app:1.19.1
iomete/iom-catalog:1.19.1
iomete/iom-core:1.19.1
iomete/iom-data-plane-init:1.19.1
iomete/iom-identity:1.19.1
iomete/iom-sql:1.19.1

# NEW Image
iomete/spark-submit-service:1.0.0

# Spark based images
iomete/spark:3.5.1-v3
iomete/spark-py:3.5.1-v3
iomete/spark-operator:3.5.1-v3
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
  -f example-data-plane-values.yaml --version 1.19.1
```

Important:
Restart lakehouses, make sure new spark-images (3.5.1-v3) and spark-operator function properly. 
