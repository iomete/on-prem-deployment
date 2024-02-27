# IOMETE Data-plane Deployment


## Add iomete helm repo

```shell
# add iomete helm repo
helm repo add iomete https://chartmuseum.iomete.com
helm repo update
```

---
## Deploy IOMETE Data Plane Base

IOMETE Data Plane Base is a base deployment for IOMETE Data Plane. It includes CRDs, ClusterRole, Lakehouse Service Account, and Roles.

### Option 1: Standard Deployment

Deploy IOMETE Data Plane Base:

```shell
helm upgrade --install -n iomete-system data-plane-base iomete/iomete-data-plane-enterprise-base --version 1.8.0
```

### Option 2: Split CRD deployment:

```shell
# Deploy only CRDs
helm pull iomete/iomete-data-plane-enterprise-base --version 1.8.0 --untar
kubectl apply -f iomete-data-plane-enterprise-base/crds

# Deploy without CRDs
helm upgrade --install --skip-crds -n iomete-system data-plane-base iomete/iomete-data-plane-enterprise-base --version 1.8.0
```

Additional values to configure:
```shell
--set rbac.createClusterRole=false # to skip creating cluster role. Default is true
--set "imagePullSecrets[0].name=<iomete-image-pull-secret-name>" # to provide image pull secret
```


---
## Deploy IOMETE Data Plane

> Note: Make sure `data-plane-values.yaml` is correctly configured.

```shell
helm upgrade --install -n iomete-system iomete-dataplane iomete/iomete-data-plane-enterprise -f data-plane-values.yaml --version 1.8.0
```