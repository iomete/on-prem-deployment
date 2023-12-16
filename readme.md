# IOMETE On-Premise Self-serve Deployment Guide

IOMETE can be deployed on-premise in a Kubernetes cluster. This guide will walk you through the steps to deploy IOMETE on-premise.

## Prerequisites

- Kubernetes cluster with at least 1 data node (4 CPU, 8GB RAM)
  - Given resources will be used by IOMETE controller and Spark driver & executor pods.
    - IOMETE Controller (1CPU, 4GB RAM)
    - Spark Driver (The rest of the resources (cpu, mem))
  - Node configuration recommendations:
    - Uniform nodes size are recommended for simplicity and ease of management.
    - Bigger node/VM sizes are recommended for better resource utilization.
- Object storage: Minio, DELL ECS, IBM Cloud Object Storage, AWS S3, Azure Blob Storage, Google Cloud Storage, etc.
- A storage class with at least 10GB of storage. The storage class should support ReadWriteMany access mode. For example, you can use the following storage class:
- Tools
  - kubectl
  - helm
  - aws cli (to connect to the object storage)

Rest of the hardware resources will be used by Spark driver and executors.

## Hardware Requirements

IOMETE controller requires 2 CPU and 4GB of RAM. Spark driver and executors will use the rest of the resources. 
> Note: We recommend using at least 4 CPU and 8GB of RAM for the data node.

## Deployment

> Note: Make sure you have configured the `kubectl` to point to the correct cluster (context).
> Note: Clone this repo and switch the current directory to this directory.

### 1. Prepare Buckets in Object Storage

Optionally, you can deploy test minio deployment
```shell
kubectl apply -f files/minio-test-deployment.yaml
```

Create dedicated 2 buckets in your object storage. One for the lakehouse and the other for assets.

- Lakehouse bucket: This bucket will be used to store the data lakehouse (data lake).
- Assets bucket: This bucket will be used to store the assets (logs, spark history data, sql result cache, etc.)

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

# create `spark-history` folder in assets bucket
aws s3api put-object --bucket assets --key spark-history/ --content-length 0

# verify buckets
aws s3 ls
```

### 2. Deploy Namespace & Service Account

```shell
kubectl create namespace iomete

# add iomete helm repo
helm repo add iomete https://chartmuseum.iomete.com
helm repo update

helm upgrade --install -n iomete lakehouse-service-account iomete/iomete-lakehouse-service-account
```


### 3. Deploy FluxCD

IOMETE uses FluxCD to deploy and manage the IOMETE components. FluxCD is a GitOps operator for Kubernetes.

Add `fluxcd` helm repo
```shell
helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts
helm repo update
```

Install FluxCD

```shell
# You can skip this if you already have fluxcd installed in your cluster.
helm upgrade --install --namespace fluxcd \
  --create-namespace fluxcd fluxcd-community/flux2 \
  --version 2.10.0 \
  --set imageAutomationController.create=false \
  --set imageReflectionController.create=false \
  --set kustomizeController.create=false \
  --set notificationController.create=false      
```

And deploy IOMETE repository. This repository contains the IOMETE helm charts.
```shell
kubectl apply -n iomete -f files/iomete-helm-repo.yaml
```


### 4. Deploy ISTIO

```shell
kubectl apply -n iomete -f files/istio.yaml
```

### 5. Prepare Database

Skip this step if you already have a mysql database instance.

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install -n iomete -f files/mysql-values.yaml mysql bitnami/mysql
```

### 6. Deploy IOMETE Data Plane

> Note: Make sure `data-plane-values.yaml` is configured correctly.

```shell
helm upgrade --install -n iomete iomete-dataplane iomete/iomete-dataplane -f files/data-plane-values.yaml --version 1.4.0
```

### 7. Control Plane Configuration

If you have enabled the `controlPlane.enabled` in the `data-plane-values.yaml` file, you need to manually configure the control plane. Otherwise, skip this step.  
  
After installing data-plane instances and configuring DNS, connect to your mysql instance and insert the following record in the `iomete_control_plane_db` database. You should insert a record for each data-plane instance. For example if you have 2 data-plane instances, you should insert 2 records.

```sql
insert into iomete_control_plane_db.data_plane (id, name, cloud, region, endpoint) 
values ('1', 'data-plane-name', 'on-prem', 'us-east-1', 'https://data-plane-dns.company.com');

insert into iomete_control_plane_db.data_plane (id, name, cloud, region, endpoint) 
values ('2', 'data-plane-2-name', 'on-prem', 'us-east-1', 'https://data-plane-2-dns.company.com');
```

| Column   | Description                     |
| -------- | ------------------------------- |
| id       | Unique ID                       |
| name     | Data Plane display name         |
| cloud    | Cloud provider                  |
| region   | Region, `us-east-1` for on-prem |
| endpoint | Data-plane host                 |


### 8. DNS Configuration

To configure the DNS for your data-plane instance, you need to retrieve the external IP address. 
This IP address can be from a load balancer or a node port, depending on your setup. This external IP is associated with the Istio ingress in the `istio-system` namespace.  

Follow these steps:  

1. To get the external IP address, use the following `kubectl` command:
    
    ```shell
    kubectl get svc istio-ingress -n istio-system
    ```
    
    Look for the `EXTERNAL-IP` field in the output. This is the IP address you'll use for DNS configuration.

2. Use the retrieved external IP address to configure your DNS settings. This process will vary depending on your DNS provider or your internal DNS configuration system.


## Multi-Catalog Configuration

To integrate additional Spark catalogs, append the following entries in the `data-plane-values.yaml` file, under the `storage → catalogs` section:

```yaml
storage:
  catalogs:
    # This is the default system catalog. Please do not modify it.
    spark_catalog:
      bucketName: lakehouse
    # Add the following lines for a new catalog
    new_catalog:
      bucketName: lakehouse_new_catalog
```

This configuration allows the use of the same storage credentials but targets a different lakehouse bucket for data storage.

If you need to use distinct storage credentials or connect to a different S3-compatible storage instance, specify `credentials` as shown below:

```yaml
storage:
  catalogs:
    # This is the default system catalog. Please do not modify it.
    spark_catalog:
      bucketName: lakehouse
		# Add the following lines for a new catalog
    new_catalog:
      bucketName: lakehouse_new_catalog
      credentials:
        endpoint: "..."
        region: "us-east-1"
        accessKey: "..."
        secretKey: "..."
        # Uncomment and use the following lines if you need to use secret keys
        # secretKeySecret:
        #   name: secret-name
        #   key: secret-key
```

By default, the new catalog remains invisible in the SQL Explorer if it contains no tables. To make the catalog visible, create a table using the following SQL command:

```sql
create table new_catalog.default.sample_table(data string);
```

Specify the catalog name, database name, and table name manually. After refreshing the SQL Explorer, the `new_catalog` should appear alongside the default `spark_catalog`.