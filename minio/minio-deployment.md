# Deploy Minio & Prepare Buckets

To deploy a test Minio deployment

```shell
kubectl apply -n iomete-system -f minio/minio-test-deployment.yaml
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
export AWS_ENDPOINT_URL=http://localhost:9000

# create s3 bucket
aws s3 mb s3://lakehouse

# verify buckets
aws s3 ls
```