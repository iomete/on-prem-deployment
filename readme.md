# IOMETE On-Premise Self-serve Deployment Guide (Private Preview)

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

### 2. Deploy FluxCD

IOMETE uses FluxCD to deploy and manage the IOMETE components. FluxCD is a GitOps operator for Kubernetes.

Add `fluxcd` helm repo
```shell
helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts
helm repo update
```

Install FluxCD

```shell
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
kubectl create namespace iomete-system
kubectl apply -f files/iomete-helm-repo.yaml
```

### 3. Deploy data plane secret

Example (see: `files/iomete-data-plane-secret-with-minio.json`):
```json
{
  "cloud": "on-prem",
  "region": "us-east",
  "cluster_name": "on-prem-staging",
  "storage_configuration": {
    "minio": {
      "enabled": "true",
      "host": "http://minio.default.svc.cluster.local:9000",
      "access_key": "admin",
      "secret_key": "password",
      "lakehouse_bucket_name": "lakehouse",
      "assets_bucket_name": "assets"
    }
  }
}
```

- `cloud`: To specify the cloud provider. For on-premise deployments, use `local`.
- `region`: To specify the closest region to the cluster. At this moment only us-east is supported. More regions will be added soon.
- `cluster_name`: Name of the cluster. Can be any name. It will be shown in the IOMETE UI.
- `storage_configuration`: To specify the storage configuration. On
  - `minio`: To specify the Minio configuration. Only one of the storage configurations should be enabled.
    - `enabled`: To enable/disable Minio.
    - `host`: Minio endpoint (host:port). For example: `minio.default.svc.cluster.local:9000`
    - `access_key`: Minio access key.
    - `secret_key`: Minio secret key.
    - `lakehouse_bucket_name`: Name of the lakehouse bucket.
    - `assets_bucket_name`: Name of the assets bucket.
  - `dell_ecs`: Dell ECS configuration is similar to Minio configuration. See: `files/iomete-data-plane-secret-with-dell-ecs.json`


Once you configure the data plane secret json file, deploy it to the cluster.

```shell
kubectl create secret -n iomete-system generic iomete-data-plane-secret --from-file=settings=files/iomete-data-plane-secret-with-minio.json
```

### 4. Deploy IOMETE Agent

IOMETE agent is the component that keep the connection with IOMETE control plane. 
Once you deploy the agent, it will connect to the control plane and start listening for the commands. 
Rest of the deployment will be handled by the IOMETE control plane through the agent.

In the `files/iomete-agent.yaml` you will find the following properties:
```yaml
values:
  # !!! The following values are examples. Replace them with your own values.
  iometeAccountId: "acc_i7hP16JyhffRMkVa"
  ingressSettings:
    hosts:
      - 20.106.203.251
    port: 30537
    https: true
```

- `iometeAccountId`: Your IOMETE account id. You can create account and copy account id using the IOMETE console: https://devapp.iomete.cloud/settings/orgs
- `ingressSettings`: Data plane connection access point. This can be a load balancer, a node port or DNS that points one of these. 
  - `hosts`: List of hosts (LB IP, Data Node IP, or DNS) that can be used to connect to the data plane. 
  - `port`: Port number to connect to the data plane. Can be LB or Node Port's port number. In the Node Port case, just leave it any port number. After installation complete, you can find the port number from the istio-ingress service and redeploy agent.
  - `https`: Whether to use https or not. https=true is highly recommended.

Based on this, IOMETE create a DNS records (`<random_subdomain>.iomete.cloud` - e.g. `yl5p5b61.iomete.cloud`) which points to the given hosts. In https case, IOMETE also deploys necessary certificates to the data plane. No need to configure anything on the data plane side.

```shell
kubectl apply -f files/iomete-agent.yaml
```

Go to IOMETE console to see the data plane installation progress: https://devapp.iomete.cloud/settings/orgs

> Note: It could take a few seconds to see the data plane installation progress.




