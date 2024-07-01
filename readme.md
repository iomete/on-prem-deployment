# IOMETE On-Premises Deployment Guide (1.16)

This guide provides detailed instructions for deploying IOMETE on-premises within a Kubernetes environment, ensuring you have a seamless setup process.

## Essential Requirements Before You Start

Before initiating the deployment, ensure your system meets the following prerequisites:

- **Kubernetes Cluster:** Your cluster should include at least one data node with the following specifications:
  - **Minimum Specs for Data Node:** 4 CPU cores and 32GB of RAM.
  - **Resource Allocation:**
    - **IOMETE Controller:** Requires 2 CPU cores and 4GB of RAM.
    - **Spark Driver:** Utilizes the remaining CPU cores and memory.
- **Node Configuration Tips:**
  - Opt for uniform node sizes to simplify management.
  - Larger nodes or VMs provide improved resource efficiency.
- **Object Storage:** Have one of the following ready: Minio, DELL ECS, IBM Cloud Object Storage, AWS S3, Azure Blob Storage, or Google Cloud Storage.
- **Necessary Tools:**
  - `kubectl` for cluster interaction.
  - `helm` for package management.
  - `aws cli` for object storage connectivity.

## Hardware Recommendations

For optimal performance:
- The IOMETE controller should have 4 CPU cores and 8GB RAM.
- It's advisable to equip the data node with a minimum of 4 CPU cores and 32GB RAM.

## Deployment Steps

> For upgrade instructions, refer to the [Upgrade Guide](releases/1.11.0/upgrade.md)

Ensure you're targeting the right Kubernetes cluster with `kubectl` and have the necessary repository cloned.

### Setting Up the IOMETE Namespace

A dedicated namespace for IOMETE is recommended for better organization. Create it using the following command:

```shell
kubectl create namespace iomete-system
```

#### Optional: Deploying Minio

If you lack an object storage system, consider deploying Minio, object storage solution. Follow the instructions [here](minio/minio-deployment.md).

#### Optional: Database Configuration

If you don't have a PostgreSQL database, deploy one using the instructions [here](database/postgresql-deployment.md).

### Integrating IOMETE Helm Repository

Add the IOMETE helm repository for access to necessary charts:

```shell
helm repo add iomete https://chartmuseum.iomete.com
helm repo update
```

### Generating Certificates

```shell
./gencerts.sh -n iomete-system -s spark-operator-webhook -r spark-operator-webhook-certs
```

### Deploying IOMETE Data Plane Base

IOMETE Data Plane Base is a base deployment for IOMETE Data Plane. It includes CRDs, ClusterRole, Lakehouse Service Account, and Roles.

```shell
helm upgrade --install -n iomete-system data-plane-base \
  iomete/iomete-data-plane-base --version 1.13
```
See the [IOMETE Data Plane Base Helm Chart](helm/iomete-data-plane-base/readme.md) for more details.

### Launching IOMETE Data Plane

Ensure your `data-plane-values.yaml` file is correctly configured before deploying the IOMETE Data Plane:

```shell
# helm repo update iomete
helm upgrade --install -n iomete-system data-plane \
  iomete/iomete-data-plane-enterprise \
  -f example-data-plane-values.yaml --version 1.16
```

For more details, refer to the [IOMETE Data Plane Helm Chart](helm/iomete-data-plane-enterprise/readme.md).

### Setting Up Ingress

For ingress configuration, refer to the [Istio Deployment guide](istio-ingress/istio-deployment.md).

By following these steps, you'll have IOMETE successfully deployed on-premises, ready to empower your data-driven decisions.
