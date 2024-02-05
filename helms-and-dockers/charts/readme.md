
After moving Helm charts to your private registry, please update urls in the following Helm Repositories:


```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: iomete
  namespace: iomete-system
spec:
  interval: 10s
  timeout: 60s
  url: https://chartmuseum.iomete.com # update this url if you are using your own private registry
```