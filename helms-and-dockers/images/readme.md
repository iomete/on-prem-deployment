# Docker Images - Migrating to Customer's Registry

Sometimes, the environment where you are deploying your application may not have access to the public Docker Hub registry. In such cases, you may need to migrate the images to a private registry. This can be done by pulling the images from the public registry and pushing them to the private registry. 
This process is automated with the provided Makefile in this directory.

## Overview

1. **TARGET_REPO**: This variable defines the target repository to which the images will be pushed. Please, specify your target repository in the `Makefile`.
2. **IMAGES**: This variable reads the list of images from an external file `images.list`. It contains all the IOMETE docker images already that are in the public Docker Hub registry.

For each image in the `IMAGES` list, the Makefile performs three steps:
   - Pull the image from the source repository which is IOMETE's public Docker Hub registry.
   - Tag the image with the target repository.
   - Push the image to the target repository.

## Run

> Note: Ensure you are logged into your Docker registry before running this Makefile. Source docker images are already in the public Docker Hub registry.

```shell
make
```


## Additional Docker Images

Apart from the images in the `images.list` file, there are a few more images that need to be migrated to your Docker registry.
These images are istio, fluxcd, minio, and postgresql images.

```shell
docker.io/bitnami/postgresql:16.1.0-debian-11-r24
docker.io/istio/pilot:1.17.2
docker.io/istio/proxyv2:1.17.2
ghcr.io/fluxcd/helm-controller:v0.36.0
ghcr.io/fluxcd/source-controller:v1.1.0
minio/minio
```
