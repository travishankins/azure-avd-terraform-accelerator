# Example: Production Deployment with All Features Enabled

This example demonstrates how to deploy AVD with backup, image gallery, and policy modules enabled.

## Quick Start

1. **Copy the example tfvars file:**
   ```bash
   cp terraform-all-features.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars with your values:**
   - Update `resource_prefix`, `location`, `environment`
   - Configure domain join settings
   - Adjust email addresses for notifications
   - Review and customize retention policies

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## What Gets Deployed

### Core Infrastructure (Already Existing)
- ✅ Resource Group
- ✅ Virtual Network (or uses existing)
- ✅ Log Analytics Workspace
- ✅ Key Vault
- ✅ Storage Account (Premium Files for FSLogix)
- ✅ AVD Host Pool, Workspace, Application Groups
- ✅ Session Host VMs with availability zones

### NEW: Backup Module
- ✅ Recovery Services Vault
- ✅ Backup Policy with customizable retention
- ✅ Automatic protection for all session hosts
- ✅ Daily backups at 2 AM with 30-day retention
- ✅ Weekly (12 weeks), Monthly (12 months), Yearly (5 years) retention

### NEW: Image Gallery Module
- ✅ Shared Image Gallery
- ✅ Windows 11 Multi-Session image definition
- ✅ RBAC for CI/CD pipeline (optional)
- ✅ Versioned image management

### NEW: Policy Module
- ✅ Require Managed Disks policy
- ✅ Allowed VM Sizes restriction
- ✅ Environment Tag requirement
- ✅ Microsoft Antimalware deployment
- ✅ Disk Encryption auditing
- ✅ VM Diagnostic Settings automation

## Feature Toggles

All new features are **disabled by default** for backward compatibility. Enable them by setting:

```hcl
# In your terraform.tfvars file
enable_backup        = true
enable_image_gallery = true
enable_policies      = true
```

## Cost Implications

Enabling the new modules will add the following costs:

| Feature | Estimated Monthly Cost | Value |
|---------|------------------------|-------|
| **Azure Backup** | ~$10-30/VM | Business continuity, compliance |
| **Shared Image Gallery** | ~$5/month | Faster deployments, consistency |
| **Azure Policy** | Free | Governance, compliance, security |

**Note:** Costs vary by region, backup retention, and VM count.

## Next Steps

After deployment with all features enabled:

1. **Backup:**
   - Test VM restoration
   - Configure backup alerts
   - Document recovery procedures

2. **Image Gallery:**
   - Build your first golden image
   - Set up CI/CD pipeline for image updates
   - Plan update rings strategy

3. **Policy:**
   - Review policy compliance reports
   - Add custom policies as needed
   - Integrate with Azure Security Center

## Support

See RECOMMENDATIONS.md for detailed best practices and implementation guidance.
