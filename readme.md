# IOMETE On-Premises Deployment Guide

IOMETE can be deployed on-premises within a Kubernetes cluster. This guide will help you through the steps to deploy IOMETE on-premises.

## Prerequisites

- A Kubernetes cluster with at least one data node (4 CPU, 32GB RAM). Allocated resources will be utilized by the IOMETE controller and Spark driver & executor pods.
  - IOMETE Controller (2CPU, 4GB RAM)
  - Spark Driver (Remaining resources (CPU, memory))
- Node configuration recommendations:
  - Uniform node size is recommended for simplicity and ease of management.
  - Bigger node/VM sizes will yield better resource utilization.
- An object storage system: Minio, DELL ECS, IBM Cloud Object Storage, AWS S3, Azure Blob Storage, Google Cloud Storage, and others.
- Tools
  - kubectl
  - helm
  - aws cli (for connection to the object storage)

## Hardware Requirements

The IOMETE controller requires 2 CPU and 4GB of RAM. The Spark driver and executors will use the remaining resources.
> Note: It's recommended to use at least 4 CPU and 32GB of RAM for the data node.

## Deployment

> Note: Make sure `kubectl` is configured to point to the correct cluster (context).
> Note: Clone this repo and change the current directory to this directory.

---
### 1. Deploy Minio (Optional)

[Deploy Minio](minio/minio-deployment.md) if you don't have an object storage system. Minio is an open-source object storage system that can be deployed on-premises.

---
### 2. Create iomete namespace
```shell
kubectl create namespace iomete-system
kubectl label namespace iomete-system istio-injection=enabled
```

---
### Prepare Database

IOMETE supports PostgreSQL as backend database. Following the instructions below, you will deploy a PostgreSQL database using Helm from the Bitnami repository.

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install -n iomete-system -f database/postgresql-values.yaml postgresql bitnami/postgresql
```

> _Info: The database will be ready in about 30-40 seconds._

---
### Deploy ISTIO

Add istio helm repository:
```shell
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

Deploy istio helm charts:
```shell
helm upgrade --install -n iomete-system  base istio/base --version 1.17.2 --set global.istioNamespace=iomete-system
# In `istio/istio-mesh-config-values.yaml`: replace `iomete-system` with the namespace where IOMETE is installed if it is different
helm upgrade --install -n iomete-system istiod istio/istiod --version 1.17.2 --set global.istioNamespace=iomete-system --set global.oneNamespace=true -f istio/istio-mesh-config-values.yaml
helm upgrade --install -n iomete-system istio-ingress istio/gateway --version 1.17.2
```

See [Istio Deployment](istio/istio-deployment.md) for other deployment options.

----
### Deploy FluxCD

IOMETE utilizes FluxCD to deploy and manage IOMETE components. FluxCD is a GitOps operator for Kubernetes.

Add fluxcd helm repo:
```shell
helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts
helm repo update
```

Deploy FluxCD:
```shell
kubectl create namespace fluxcd
helm upgrade --install -n fluxcd fluxcd fluxcd-community/flux2 \
  --version 2.10.0 \
  --set imageAutomationController.create=false \
  --set imageReflectionController.create=false \
  --set kustomizeController.create=false \
  --set notificationController.create=false  
```

See [FluxCD Deployment](fluxcd/fluxcd-deployment.md) for other deployment options.

---
### Deploy IOMETE Data Plane Base

IOMETE Data Plane Base is a base deployment for IOMETE Data Plane. It includes CRDs, ClusterRole, Lakehouse Service Account, and Roles.

Add iomete helm repo:
```shell
# add iomete helm repo
helm repo add iomete https://chartmuseum.iomete.com
helm repo update
```


Deploy IOMETE Data Plane Base:

```shell
helm upgrade --install -n iomete-system data-plane-base iomete/iomete-data-plane-enterprise-base --version 1.8.0
```

See [IOMETE Data-plane Deployment](data-plane-deployment.md) for other deployment options.


---
### Deploy IOMETE Data Plane

> Note: Make sure `data-plane-values.yaml` is correctly configured.

```shell
helm upgrade --install -n iomete-system iomete-dataplane iomete/iomete-data-plane-enterprise -f data-plane-values.yaml --version 1.8.0
```

### DNS Configuration

To configure DNS for your data plane instance, retrieve the external IP address. Depending on your setup, this IP address could be from a load balancer or a node port. This external IP is associated with the Istio ingress in the `istio-system` namespace.

Here are the steps to follow:

1. To get the external IP address, use the following `kubectl` command:

    ```shell
    kubectl get svc istio-ingress -n istio-system
    ```

   Look for the `EXTERNAL-IP` field in the output. This is the IP address to be used for DNS configuration.

2. Use the retrieved external IP address to configure your DNS settings. The process will depend on your DNS provider or your internal DNS configuration system.

Note: Multi-catalog configuration has been moved to the web UI. Please, in the web UI, go to `Settings > Spark catalogs` to configure your catalogs.