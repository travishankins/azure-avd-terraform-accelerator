# 🚀 Integration Guide - Adding New Features to Your Deployment

## Prerequisites

You have an existing AVD deployment using this Terraform accelerator.

---

## Step-by-Step Integration

### Step 1: Add New Variables (Required)

The new modules need variable definitions. Add them to your `variables.tf`:

```bash
# Navigate to your project directory
cd /Users/travis/Developer/projects/avd-accelator-avm

# Append new variables
cat variables_new_modules.tf >> variables.tf

# Verify
tail -20 variables.tf
```

**What this does:** Adds 19 new optional variables for backup, image gallery, and policy modules.

---

### Step 2: Choose Your Deployment Path

#### Path A: Start Fresh with All Features

Best for **new deployments** or **dev/test environments**.

```bash
# Use the all-features example
cp terraform-all-features.tfvars.example terraform.tfvars

# Edit with your values
code terraform.tfvars  # Or use nano, vim, etc.

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

#### Path B: Gradually Enable Features

Best for **existing production deployments**.

```bash
# Edit your existing terraform.tfvars
code terraform.tfvars
```

Add just one feature at a time:

**Week 1 - Add Backup:**
```hcl
# Add to your terraform.tfvars
enable_backup                  = true
backup_frequency               = "Daily"
backup_time                    = "02:00"
backup_timezone                = "UTC"
backup_daily_retention_count   = 30
backup_weekly_retention_count  = 12
backup_monthly_retention_count = 12
backup_yearly_retention_count  = 5
```

```bash
terraform plan   # Review: Should show Recovery Vault + Backup Policy
terraform apply
```

**Week 2 - Add Image Gallery:**
```hcl
# Add to your terraform.tfvars
enable_image_gallery           = true
create_win11_image_definition  = true
create_win10_image_definition  = false
```

```bash
terraform plan   # Review: Should show Shared Image Gallery
terraform apply
```

**Week 3 - Add Policies:**
```hcl
# Add to your terraform.tfvars
enable_policies                = true
policy_require_environment_tag = true
policy_allowed_vm_sizes        = ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5"]
policy_deploy_antimalware      = true
policy_audit_disk_encryption   = true
policy_enable_vm_diagnostics   = true
```

```bash
terraform plan   # Review: Should show 6 policy assignments
terraform apply
```

---

### Step 3: Verify Deployment

#### Backup Module Verification

```bash
# Check Recovery Services Vault
az backup vault list --resource-group <your-rg-name> --output table

# Check backup jobs
az backup job list --resource-group <your-rg-name> --vault-name <vault-name> --output table

# Check protected items
az backup item list --resource-group <your-rg-name> --vault-name <vault-name> --output table
```

**Azure Portal:**
1. Navigate to Recovery Services Vault
2. Go to "Backup Items" → "Azure Virtual Machine"
3. Verify all session hosts are protected

#### Image Gallery Verification

```bash
# Check Shared Image Gallery
az sig list --resource-group <your-rg-name> --output table

# Check image definitions
az sig image-definition list --resource-group <your-rg-name> --gallery-name <gallery-name> --output table
```

**Azure Portal:**
1. Navigate to Shared Image Gallery
2. Verify image definitions created
3. (Later) Check image versions after building golden images

#### Policy Verification

```bash
# Check policy assignments
az policy assignment list --resource-group <your-rg-name> --output table

# Check compliance state
az policy state summarize --resource-group <your-rg-name>
```

**Azure Portal:**
1. Navigate to Policy → Compliance
2. Verify 6 policy assignments
3. Check compliance status (may take 30 min for initial evaluation)

---

## Rollback Plan

If you need to disable a feature:

### Disable Backup
```hcl
# In terraform.tfvars
enable_backup = false
```

```bash
terraform plan   # Review: Will destroy Recovery Vault
terraform apply
```

**⚠️ WARNING:** This will delete all backup data. Ensure you don't need recovery points!

### Disable Image Gallery
```hcl
# In terraform.tfvars
enable_image_gallery = false
```

```bash
terraform plan   # Review: Will destroy Image Gallery
terraform apply
```

**⚠️ WARNING:** This will delete image definitions. Any built images will be lost!

### Disable Policies
```hcl
# In terraform.tfvars
enable_policies = false
```

```bash
terraform plan   # Review: Will remove policy assignments
terraform apply
```

**✅ SAFE:** Policy removal doesn't affect existing resources.

---

## Troubleshooting

### Issue: "No declaration found for var.enable_backup"

**Solution:** You need to add the new variables to `variables.tf`:
```bash
cat variables_new_modules.tf >> variables.tf
```

### Issue: Terraform plan shows no changes

**Check:**
1. Did you set `enable_backup = true` (or other feature) in terraform.tfvars?
2. Did you run `terraform init` after adding new modules?

**Solution:**
```bash
terraform init
terraform plan -var-file=terraform.tfvars
```

### Issue: Policy assignment fails with "insufficient permissions"

**Solution:** Your Terraform service principal needs these permissions:
```bash
# Add Policy Contributor role
az role assignment create \
  --assignee <service-principal-id> \
  --role "Resource Policy Contributor" \
  --scope "/subscriptions/<subscription-id>"
```

### Issue: Backup vault creation fails

**Common causes:**
- Vault name must be unique per region
- Requires `Microsoft.RecoveryServices` provider registered

**Solution:**
```bash
# Register provider
az provider register --namespace Microsoft.RecoveryServices

# Check registration
az provider show --namespace Microsoft.RecoveryServices --query "registrationState"
```

---

## Testing Your Deployment

### Test Backup

1. **Wait for first backup** (scheduled at 02:00 UTC by default)
2. **Or trigger on-demand backup:**
   ```bash
   az backup protection backup-now \
     --resource-group <rg-name> \
     --vault-name <vault-name> \
     --container-name <vm-container-name> \
     --item-name <vm-name> \
     --backup-management-type AzureIaaSVM \
     --retain-until 30-12-2025
   ```

3. **Test restore:**
   - Azure Portal → Recovery Services Vault
   - Backup Items → Azure Virtual Machine
   - Select VM → Restore VM
   - Choose restore point → Create new VM (test)

### Test Image Gallery

1. **Build a golden image:**
   ```bash
   # Option 1: Use Azure Image Builder (recommended)
   # See: https://learn.microsoft.com/azure/virtual-machines/image-builder-overview
   
   # Option 2: Manually create from existing VM
   az vm deallocate --resource-group <rg> --name <source-vm>
   az vm generalize --resource-group <rg> --name <source-vm>
   az sig image-version create \
     --resource-group <rg> \
     --gallery-name <gallery-name> \
     --gallery-image-definition <image-def-name> \
     --gallery-image-version 1.0.0 \
     --managed-image /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/<source-vm>
   ```

2. **Deploy session host from custom image:**
   - Update `modules/compute/variables.tf` to support custom images
   - Or manually test: Create VM from gallery image version

### Test Policies

1. **Check compliance:**
   ```bash
   az policy state summarize --resource-group <rg-name>
   ```

2. **Test enforcement:**
   - Try creating a VM with non-allowed size (should fail)
   - Try creating a resource without Environment tag (should fail/warn)

---

## Performance Monitoring

After enabling new features, monitor:

### Backup
- **First backup duration:** 1-4 hours (depending on VM size)
- **Incremental backups:** 10-30 minutes
- **Impact on VMs:** Minimal (< 5% CPU during backup)

### Image Gallery
- **Gallery creation:** < 1 minute
- **Image version creation:** 30-60 minutes (first time)
- **VM deployment from custom image:** 5-10 minutes (vs 10-15 from marketplace)

### Policies
- **Assignment:** Immediate
- **First compliance scan:** 30 minutes
- **Ongoing scans:** Every 24 hours
- **Performance impact:** None (policies evaluated on create/update only)

---

## Cost Monitoring

Enable cost tracking for new features:

```bash
# View costs by resource type
az consumption usage list \
  --start-date 2025-10-01 \
  --end-date 2025-10-07 \
  --query "[?contains(instanceName, 'backup') || contains(instanceName, 'gallery')]" \
  --output table
```

**Expected costs (US East):**
- Backup: $10-30/VM/month
- Image Gallery: $5/month
- Policies: $0 (free)

---

## Next Steps

1. ✅ **Document your configuration** - Save your terraform.tfvars
2. ✅ **Set up alerts** - Add Azure Monitor alerts for backup failures
3. ✅ **Plan image updates** - Schedule quarterly golden image refreshes
4. ✅ **Review compliance** - Weekly policy compliance checks
5. ✅ **Test DR** - Quarterly backup restore tests

---

## Additional Resources

- **Full Best Practices:** `RECOMMENDATIONS.md`
- **Feature Overview:** `NEW-FEATURES.md`
- **Quick Start:** `EXAMPLE-ALL-FEATURES.md`
- **Change Summary:** `SUMMARY.md`

---

**Questions? Check the module source code in `modules/*/` or review the comprehensive examples.**
