# Deploying ISTIO for Kubernetes Ingress

This guide walks you through the process of installing ISTIO as an ingress controller on a Kubernetes cluster and configuring it for use with IOMETE.
# Detailed Guide: Deploying ISTIO for Kubernetes Ingress

This comprehensive guide walks you through the process of installing ISTIO as an ingress controller on a Kubernetes cluster.

## Initial Setup: Adding the ISTIO Helm Repository

```shell
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

## Deploying ISTIO

If ISTIO isn't already installed on your cluster, proceed with the following deployment steps:

### Deploy ISTIO Components via Helm

Execute these commands to install the necessary ISTIO components:

```shell
helm upgrade --install -n istio-system base istio/base --version 1.17.2
helm upgrade --install -n istio-system istiod istio/istiod --version 1.17.2
helm upgrade --install -n istio-system istio-ingress istio/gateway --version 1.17.2
```

## Configuring the Gateway

### For HTTP (Non-TLS Mode)

Apply the following configuration for an HTTP gateway:

```shell
kubectl -n istio-system apply -f istio-ingress/resources/gateway-http.yaml
```

### For HTTPS (TLS Mode)

To set up a secure gateway using TLS:

1. **Create a TLS Secret:** Use the template below, replacing placeholder values with your actual base64 encoded certificate and key.

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: tls-secret # Replace with your secret name
   data:
     tls.crt: >-
       <base64 encoded certificate>
     tls.key: >-
       <base64 encoded private key>
   type: kubernetes.io/tls
   ```

2. **Deploy the HTTPS Gateway:** After creating the secret, apply the HTTPS gateway configuration.

```shell
kubectl -n istio-system apply -f istio-ingress/resources/gateway-https.yaml
```

## DNS Configuration for Access

To make your service accessible via a domain name, configure DNS to point to the ISTIO ingress.

### Retrieving the External IP Address

Run this command to fetch the external IP address of the ISTIO ingress:

```shell
kubectl get svc istio-ingress -n istio-system
```

Look for the `EXTERNAL-IP` column in the command output.

### Setting Up DNS

With the external IP in hand, update your DNS settings to direct traffic to this IP. The specific steps will depend on your DNS provider or internal DNS system.

By following these steps, you'll have ISTIO set up as an ingress controller in your Kubernetes cluster.