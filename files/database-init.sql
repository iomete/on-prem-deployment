# prefix: iomete_
CREATE DATABASE iomete_core_db;
CREATE DATABASE iomete_iam_db;
CREATE DATABASE iomete_sql_db;
CREATE DATABASE iomete_iceberg_db;
CREATE DATABASE iomete_metastore_db;
CREATE DATABASE iomete_keycloak_db;
CREATE DATABASE iomete_ranger_db;

CREATE USER iomete_user@'%' IDENTIFIED BY 'iomete_pass';
GRANT ALL PRIVILEGES ON iomete_core_db.* TO iomete_user@'%';
GRANT ALL PRIVILEGES ON iomete_iam_db.* TO iomete_user@'%';
GRANT ALL PRIVILEGES ON iomete_sql_db.* TO iomete_user@'%';
GRANT ALL PRIVILEGES ON iomete_iceberg_db.* TO iomete_user@'%';
GRANT ALL PRIVILEGES ON iomete_metastore_db.* TO iomete_user@'%';
GRANT ALL PRIVILEGES ON iomete_keycloak_db.* TO iomete_user@'%';
GRANT ALL PRIVILEGES ON iomete_ranger_db.* TO iomete_user@'%';

FLUSH PRIVILEGES;