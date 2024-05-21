# Release Notes

## IOMETE 1.10.0

### New Features

#### Register Iceberg Table from S3 Location
Enables the creation of a catalog entry for an existing Iceberg table located in S3 that does not currently have a catalog identifier. **Important Note**: Avoid registering the same Iceberg table in more than one catalog to prevent data inconsistencies and potential corruption. Utilizes the [Register Table](https://iceberg.apache.org/docs/latest/spark-procedures/#register_table) procedure from the Iceberg system.

#### Snapshot Parquet Table
Allows the creation of a lightweight Iceberg table over an existing Parquet table folder without modifying the original source table. The snapshot table can be altered or written to independently of the source table while using the original data files. Employs the [snapshot](https://iceberg.apache.org/docs/latest/spark-procedures/#snapshot) procedure from the Iceberg system.

#### Configurable Logging Sources 
Users now have the flexibility to choose their logging source. Previously, only Loki was supported. Now, users can choose between Kubernetes, Loki, and Elasticsearch.
- Kubernetes: Displays logs only for active/current resources and does not include historical data (e.g., logs for terminated resources are not available).
- Elasticsearch: Requires an SSL connection and an API key for authentication.

### Enhancements

#### Pod Security Context
Added securityContext settings to all pods, ensuring that all resources are running as non-root users.
- Note that Spark images requires root user only if using default hostPath volumes, which can be adjusted from Volume Settings in the IOMETE Console by choosing Dynamic PVC.
- Currently, only Apache Ranger requires root user permissions, which will be addressed in a future release.

#### Eliminated Assets Bucket
We have eliminated additional bucket created/used for assets, which was previously required for storing assets like 'sql query results', 'spark history data', etc. Now, assets are stored in the same bucket as the default lakehouse bucket.

#### Role/Permissions Settings
Redesigned and improved role/permissions settings for better user management and access control.
- Updated permissions page design for better user experience.
- IAM Settings now controlled by two permissions: View and Manage. Previously each component of IAM settings (Users / Groups / Roles) managed by separate permissions.
- Data Security / Data Catalog: List and View actions combined into a single `View` permission. Create and Manage actions combined into a single `Manage` permission.
- Added new permission for Spark Settings.
- Added new permission for Data Plane Settings.


## IOMETE 1.9.2

### New Features

- **Volume Settings**: Users can now adjust volume settings directly from the IOMETE Console. This includes selecting volume configurations for each Spark resource, with options for hostpath, dynamic PVC, and size specifications on a per-resource basis.

### Enhancements
- **Spark Connect Clusters - Connection Stability**: Issues affecting Spark Connect Cluster connections, particularly from Jupyter notebooks and Windows environments, have been addressed.
- **Spark Operator Webhook Configuration**: This can now be deployed separately. This also enabled removing ClusterRole requirements from the base Helm chart.
- **Removed Cluster Role**: The Cluster Role previously required (to control MutatingAdmissionWebhookConfiguration) for the spark-operator is removed from the base Helm chart.
- **User Permissions**: Spark clusters previously running under root user permissions are now configured to operate under non-root user permissions.
- **Grafana Metrics**: The hardcoded namespace issue in the Grafana monitoring dashboard has been resolved.
- **Bug Fixes**: Various minor issues from the last release, including Spark URL problems, have been resolved.


## IOMETE 1.9.0

### Enhanced Connectivity and Compatibility

- **SQL Client Integration:** Users can now seamlessly integrate with SQL clients like DBeaver and DataGrip to list catalogs and Iceberg tables.
- **BI Tool Support:** Enhanced connectivity with BI tools such as Tableau and PowerBI allows for direct connection to catalogs, making it easier to list and interact with Iceberg tables.

### Improved Configuration and Management

- **LDAP Configuration:** The IOMETE Console now supports LDAP configuration, offering a more streamlined and secure way to manage user access and authentication.
- **Advanced Spark Catalog Options:** Additional configuration capabilities have been introduced for Spark Catalog registration, providing more flexibility and control to users.
- **Custom Node Pool Configuration:** Users can now tailor node pool settings to their specific needs, allowing for optimized resource allocation and usage.
- **Resource Tagging:** The ability to add tags to various resources within the IOMETE Console improves resource management, making it easier to categorize and track Lakehouse, Spark Connect, Spark Jobs, etc.

### Enhanced User Experience

- **Jupyter Notebook Integration:** Jupyter Notebooks now support authentication using a username and API token, enhancing security and user convenience.
