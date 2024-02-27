# Deploy FluxCD

IOMETE utilizes FluxCD to deploy and manage IOMETE components. FluxCD is a GitOps operator for Kubernetes.

## Add fluxcd helm repo

```shell
helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts
helm repo update
```

## Option 1: Deploy FluxCD

If your cluster doesn't have fluxcd installed, here is the standard deployment:

```shell
helm upgrade --install -n fluxcd fluxcd fluxcd-community/flux2 \
  --version 2.10.0 \
  --set imageAutomationController.create=false \
  --set imageReflectionController.create=false \
  --set kustomizeController.create=false \
  --set notificationController.create=false
```

## Option 2: Split CRD deployment

If you want to deploy the CRDs separately, you can use the following commands:

```shell
# Deploy only CRDs
kubectl apply -f "fluxcd/crds-2.10.0"

# Deploy without CRDs
helm upgrade --install -n fluxcd fluxcd fluxcd-community/flux2 \
  --version 2.10.0 \
  --set imageAutomationController.create=false \
  --set imageReflectionController.create=false \
  --set kustomizeController.create=false \
  --set notificationController.create=false \
  --set installCRDs=false
```