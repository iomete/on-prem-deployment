# PostgreSQL Deployment

If you already have a PostgreSQL database, you can skip this step. Otherwise, deploy a PostgreSQL database using the following commands.
This is not a production-ready setup and should be used for testing purposes only.

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install -n iomete-system -f database/postgresql-values.yaml postgresql bitnami/postgresql
```