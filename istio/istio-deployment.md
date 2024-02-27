# Deploy ISTIO

## Add istio helm repository

```shell
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

---
## Option 1: Standard Deployment

If your cluster doesn't have istio installed, here is the standard deployment:

Deploy istio helm charts:
```shell
helm upgrade --install -n iomete-system  base istio/base --version 1.17.2 --set global.istioNamespace=iomete-system
# In `istio/istio-mesh-config-values.yaml`: replace `iomete-system` with the namespace where IOMETE is installed if it is different
helm upgrade --install -n iomete-system istiod istio/istiod --version 1.17.2 --set global.istioNamespace=iomete-system --set global.oneNamespace=true -f istio/istio-mesh-config-values.yaml
helm upgrade --install -n iomete-system istio-ingress istio/gateway --version 1.17.2
```

---
## Option 2: Split CRD deployment:

If you want to deploy the CRDs separately, you can use the following commands:

```shell
# Deploy only CRDs
helm pull istio/base --version 1.17.2 --untar
kubectl apply -f base/crds

# Deploy without CRDs
helm upgrade --install -n iomete-system --skip-crds  base istio/base --version 1.17.2 --set global.istioNamespace=iomete-system
# In `istio/istio-mesh-config-values.yaml`: replace `iomete-system` with the namespace where IOMETE is installed if it is different
helm upgrade --install -n iomete-system istiod istio/istiod --version 1.17.2 --set global.istioNamespace=iomete-system --set global.oneNamespace=true -f istio/istio-mesh-config-values.yaml
helm upgrade --install -n iomete-system istio-ingress istio/gateway --version 1.17.2
```

---
## Option 3: Reuse Existing ISTIO

If you already have ISTIO installed in your cluster, you can reuse it, but IOMETE data-plane requires additional configuration per data-plane namespace.

Register IOMETE external authorization configuration in `istio` configmap in your istio namespace:

Replace `<iomete-data-plane-namespace>` with your IOMETE data-plane namespace.

```shell
data:
  mesh: |-
    extensionProviders:
    - name: "iomete-authz-service.<iomete-data-plane-namespace>"
      envoyExtAuthzHttp:
        service: "iom-core.<iomete-data-plane-namespace>.svc.cluster.local"
        port: 80
        includeRequestHeadersInCheck: ["connect-cluster", "user-id", "api-token" ]
        pathPrefix: "/api/v1/iam/connect/authz"
```