# Release Notes

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


## IOMETE 2.0.0

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
