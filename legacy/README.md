# Legacy Configuration (Deprecated)

⚠️ **This configuration is deprecated. Please use the new modular structure in the root directory.**

The files in this directory represent the old flat structure and are kept for backward compatibility only.

## Migration Guide

To migrate from the legacy configuration to the new modular structure:

1. **Back up your current state**:
   ```bash
   cp terraform.tfstate terraform.tfstate.backup
   ```

2. **Use the new example**:
   ```bash
   cd ../examples/simple
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your current values
   ```

3. **Import existing resources** (if needed):
   ```bash
   # This may be necessary depending on your current state
   terraform import module.gke.google_container_cluster.primary projects/PROJECT_ID/locations/ZONE/clusters/CLUSTER_NAME
   ```

4. **Plan and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

The new modular structure provides:
- Better maintainability
- Reusable modules
- Enhanced security features
- Better documentation
- Production-ready defaults