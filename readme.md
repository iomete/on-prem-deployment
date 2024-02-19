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

### 1. Prepare Buckets in Object Storage

Optionally, you can deploy a test Minio deployment
```shell
kubectl apply -f minio/minio-test-deployment.yaml
```

Create two dedicated buckets in your object storage – one for the lakehouse and another for assets.

- Lakehouse bucket: This bucket will store the data lakehouse (data lake).
- Assets bucket: This bucket will store the assets (logs, spark history data, SQL result cache, etc.)

Example for Minio:

```shell
# export access key and secret key
export AWS_ACCESS_KEY_ID=admin
export AWS_SECRET_ACCESS_KEY=password
export AWS_REGION=us-east-1

# override aws cli endpoint to point to minio
alias aws='aws --endpoint-url http://localhost:9000'

# create s3 bucket
aws s3 mb s3://lakehouse
aws s3 mb s3://assets

# verify buckets
aws s3 ls
```


### Create iomete namespace
```shell
kubectl create namespace iomete-system
```

---
### Prepare Database

IOMETE supports PostgreSQL and MySQL as backend databases. You can use the following helm charts to deploy test database deployments.

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install -n iomete-system -f database/postgresql-values.yaml postgresql bitnami/postgresql
# or for MySQL
# helm upgrade --install -n iomete-system -f database/mysql-values.yaml mysql bitnami/mysql
```

The database will be ready in about 30-40 seconds.


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
helm upgrade --install -n iomete-system istiod istio/istiod --version 1.17.2 --set global.istioNamespace=iomete-system --set global.oneNamespace=true -f istio-mesh-config-values.yaml
helm upgrade --install -n iomete-system istio-ingress istio/gateway --version 1.17.2
```

#### Split CRD deployment:

```shell
# Deploy only CRDs
helm pull istio/base --version 1.17.2 --untar
kubectl apply -f base/crds

# Deploy without CRDs
helm upgrade --install -n iomete-system --skip-crds  base istio/base --version 1.17.2 --set global.istioNamespace=iomete-system

helm upgrade --install -n iomete-system istiod istio/istiod --version 1.17.2 --set global.istioNamespace=iomete-system --set global.oneNamespace=true
helm upgrade --install -n iomete-system istio-ingress istio/gateway --version 1.17.2
```

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
helm upgrade --install -n iomete-system fluxcd fluxcd-community/flux2 \
  --version 2.10.0 \
  --set imageAutomationController.create=false \
  --set imageReflectionController.create=false \
  --set kustomizeController.create=false \
  --set notificationController.create=false \
  --set policies.create=false \
  --set watchAllNamespaces=false  
```

#### Split CRD deployment:

```shell
# Deploy only CRDs
kubectl apply -f "fluxcd/crds-2.10.0"

# Deploy without CRDs
helm upgrade --install -n iomete-system fluxcd fluxcd-community/flux2 \
  --version 2.10.0 \
  --set imageAutomationController.create=false \
  --set imageReflectionController.create=false \
  --set kustomizeController.create=false \
  --set notificationController.create=false \
  --set policies.create=false \
  --set installCRDs=false \
  --set watchAllNamespaces=false
```

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
helm upgrade --install -n iomete-system data-plane-base iomete/iomete-data-plane-enterprise-base --version 1.7.2
```

#### Split CRD deployment:

```shell
# Deploy only CRDs
helm pull iomete/iomete-data-plane-enterprise-base --version 1.7.2 --untar
kubectl apply -f iomete-data-plane-enterprise-base/crds

# Deploy without CRDs
helm upgrade --install --skip-crds -n iomete-system data-plane-base iomete/iomete-data-plane-enterprise-base --version 1.7.2
```

Additional values to configure:
```shell
--set rbac.createClusterRole=false # to skip creating cluster role. Default is true
--set "imagePullSecrets[0].name=<iomete-image-pull-secret-name>" # to provide image pull secret
```


---
### Deploy IOMETE Data Plane

> Note: Make sure `data-plane-values.yaml` is correctly configured.

```shell
helm upgrade --install -n iomete-system iomete-dataplane iomete/iomete-data-plane-enterprise -f data-plane-values.yaml --version 1.7.2
```

---
### Control Plane Configuration

If you've enabled `controlPlane.enabled` in the `data-plane-values.yaml` file, you'll need to manually configure the control plane. Otherwise, skip this step.

After installing data-plane instances and configuring DNS, connect to your MySQL instance and insert the following record in the `iomete_control_plane_db` database. Insert a record for each data-plane instance. For example, if you have 2 data-plane instances, insert 2 records.

```sql
insert into iomete_control_plane_db.data_plane (id, name, cloud, region, endpoint) 
values ('1', 'data-plane-name', 'on-prem', 'us-east-1', 'https://data-plane-dns.company.com');

insert into iomete_control_plane_db.data_plane (id, name, cloud, region, endpoint) 
values ('2', 'data-plane-2-name', 'on-prem', 'us-east-1', 'https://data-plane-2-dns.company.com');
```

| Column   | Description                      |
| -------- |----------------------------------|
| id       | Unique identifier                |
| name     | Data Plane display name          |
| cloud    | Cloud provider                   |
| region   | Region (`us-east-1` for on-prem) |
| endpoint | Data-plane host                  |


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