# ARM Template - New Production Features

## 🎉 What's New in the ARM Template

The **Deploy to Azure** button now supports three new optional production features:

### 1. 🔐 **Azure Backup** (Optional)
Automatically protect session host VMs with Azure Backup.

**What gets deployed:**
- Recovery Services Vault
- Backup Policy with configurable retention (7-180 days)
- Automatic protection for all session hosts
- Daily backups at 2:00 AM UTC

**Cost:** ~$10-30 per VM per month

**When to enable:**
- ✅ Production environments
- ✅ Compliance requirements
- ✅ Business continuity needs

---

### 2. 🖼️ **Shared Image Gallery** (Optional)
Create a gallery for managing golden images.

**What gets deployed:**
- Shared Image Gallery
- Windows 11 Multi-Session image definition
- Ready for custom image versions

**Cost:** ~$5 per month

**When to enable:**
- ✅ Need standardized images
- ✅ Pre-installed applications required
- ✅ Faster session host provisioning

---

### 3. 📋 **Azure Policy** (Optional)
Enforce governance and compliance standards.

**What gets deployed:**
- 3 Azure Policy assignments:
  1. **Require Managed Disks** - Prevent classic storage
  2. **Allowed VM Sizes** - Restrict to approved sizes
  3. **Require Environment Tag** - Enforce tagging standards

**Cost:** FREE

**When to enable:**
- ✅ Always (recommended for production)
- ✅ Compliance requirements
- ✅ Cost control needs

---

## 🚀 Using the Deploy to Azure Button

### Step-by-Step Guide

1. **Click the Deploy to Azure button** in the README
2. **Complete the wizard steps:**
   - **Step 1: Basics** - Resource prefix and environment
   - **Step 2: Identity Configuration** - Azure AD or Domain Services join
   - **Step 3: Network Configuration** - New or existing VNet/subnet
   - **Step 4: Session Hosts** - VM count, size, credentials
   - **Step 5: Host Pool** - Pooled or Personal, load balancing
   - **Step 6: Production Features (NEW!)** - Enable backup, image gallery, policies
   - **Step 7: Tags** - Resource tags

3. **Production Features Step Options:**

   **Azure Backup:**
   - ☐ Enable Azure Backup for session hosts
   - 📊 Daily Backup Retention: 7-180 days (default: 30)

   **Shared Image Gallery:**
   - ☐ Enable Shared Image Gallery for golden images

   **Azure Policy:**
   - ☐ Enable Azure Policy for governance
   - 🎯 Allowed VM Sizes (multi-select):
     - Standard_D2s_v5 (2 vCPU, 8 GB)
     - Standard_D4s_v5 (4 vCPU, 16 GB)
     - Standard_D8s_v5 (8 vCPU, 32 GB)
     - Standard_D16s_v5 (16 vCPU, 64 GB)
     - And more...

4. **Review + Create** - Verify configuration and deploy

---

## 📋 Feature Comparison

| Feature | Default (Unchecked) | When Enabled |
|---------|---------------------|--------------|
| **Backup** | Not deployed | Recovery Vault + Daily backups |
| **Image Gallery** | Not deployed | Gallery + Win11 image definition |
| **Policies** | Not deployed | 3 policy assignments |

---

## 💰 Cost Impact

### Without Production Features (Default)
- Session hosts (VMs)
- Storage account
- Networking
- Log Analytics
- Key Vault

**Estimated:** ~$350-500/month for 5 VMs

### With All Production Features Enabled
- Everything above, plus:
- Azure Backup: +$50-150/month (5 VMs)
- Image Gallery: +$5/month
- Azure Policy: FREE

**Estimated:** ~$405-655/month for 5 VMs

---

## 🎯 Deployment Scenarios

### Scenario 1: Development/Test
**Recommended Settings:**
- ❌ Backup: Disabled (save costs)
- ❌ Image Gallery: Disabled (not needed)
- ❌ Policies: Disabled (flexible)

**Use case:** Quick testing, demos, POC

---

### Scenario 2: Standard Production
**Recommended Settings:**
- ✅ Backup: Enabled (30-day retention)
- ❌ Image Gallery: Disabled (add later if needed)
- ✅ Policies: Enabled (governance)

**Use case:** Production without custom images

---

### Scenario 3: Enterprise Production
**Recommended Settings:**
- ✅ Backup: Enabled (90-day retention)
- ✅ Image Gallery: Enabled
- ✅ Policies: Enabled with restricted VM sizes

**Use case:** Full enterprise deployment

---

## 🔍 What Gets Created - Detailed View

### Azure Backup Resources (if enabled)

```
avd-prod-rsv (Recovery Services Vault)
├── Backup Policy: avd-prod-backup-policy
│   ├── Schedule: Daily at 2:00 AM UTC
│   ├── Retention: 7-180 days (configurable)
│   └── Instant recovery: 2 days
└── Protected Items:
    ├── avd-prod-hostpool-0
    ├── avd-prod-hostpool-1
    ├── avd-prod-hostpool-2
    └── ... (all session hosts)
```

### Image Gallery Resources (if enabled)

```
avd_prod_sig (Shared Image Gallery)
└── Image Definitions:
    └── win11-multisession-avd
        ├── OS Type: Windows
        ├── OS State: Generalized
        ├── Hyper-V Generation: V2
        └── Image Versions: (none initially, add later)
```

### Policy Resources (if enabled)

```
Resource Group Policy Assignments
├── require-managed-disks
│   └── Ensures all VMs use managed disks
├── allowed-vm-sizes
│   └── Restricts VM sizes to approved list
└── require-environment-tag
    └── Requires Environment tag on all resources
```

---

## 📊 ARM Template Parameters Added

### New Parameters

```json
{
  "enableBackup": {
    "type": "bool",
    "defaultValue": false
  },
  "backupRetentionDays": {
    "type": "int",
    "defaultValue": 30,
    "minValue": 7,
    "maxValue": 9999
  },
  "enableImageGallery": {
    "type": "bool",
    "defaultValue": false
  },
  "enablePolicies": {
    "type": "bool",
    "defaultValue": false
  },
  "policyAllowedVmSizes": {
    "type": "array",
    "defaultValue": [
      "Standard_D2s_v5",
      "Standard_D4s_v5",
      "Standard_D8s_v5",
      "Standard_D16s_v5"
    ]
  }
}
```

### New Outputs

```json
{
  "backupEnabled": {
    "type": "bool",
    "value": "[parameters('enableBackup')]"
  },
  "recoveryVaultName": {
    "type": "string",
    "value": "avd-prod-rsv or 'Not deployed'"
  },
  "imageGalleryEnabled": {
    "type": "bool"
  },
  "imageGalleryName": {
    "type": "string",
    "value": "avd_prod_sig or 'Not deployed'"
  },
  "policiesEnabled": {
    "type": "bool"
  }
}
```

---

## ✅ Verification After Deployment

### Check Backup (if enabled)

**Azure Portal:**
1. Navigate to Recovery Services Vault
2. Go to "Backup Items" → "Azure Virtual Machine"
3. Verify all session hosts are listed
4. Check "Backup Jobs" for status

**Azure CLI:**
```bash
# List backup vaults
az backup vault list --resource-group <your-rg> --output table

# List protected VMs
az backup item list \
  --resource-group <your-rg> \
  --vault-name <vault-name> \
  --backup-management-type AzureIaasVM \
  --output table
```

---

### Check Image Gallery (if enabled)

**Azure Portal:**
1. Navigate to Shared Image Gallery
2. Verify gallery exists
3. Check "Image definitions" for win11-multisession-avd

**Azure CLI:**
```bash
# List galleries
az sig list --resource-group <your-rg> --output table

# List image definitions
az sig image-definition list \
  --resource-group <your-rg> \
  --gallery-name <gallery-name> \
  --output table
```

---

### Check Policies (if enabled)

**Azure Portal:**
1. Navigate to Azure Policy
2. Go to "Compliance"
3. Filter by your resource group
4. Verify 3 policy assignments

**Azure CLI:**
```bash
# List policy assignments
az policy assignment list \
  --resource-group <your-rg> \
  --output table

# Check compliance
az policy state summarize \
  --resource-group <your-rg>
```

---

## 🔄 Updating Your Deployment

To add features to an existing deployment:

1. **Navigate to your resource group**
2. **Click "Deployments" in the left menu**
3. **Find your original deployment**
4. **Click "Redeploy"**
5. **Enable new features in the wizard**
6. **Deploy**

**Note:** This will only add the new resources, existing resources remain unchanged.

---

## 🛡️ Backward Compatibility

✅ **100% compatible** with existing deployments  
✅ **All features disabled by default** - opt-in only  
✅ **No impact on existing deployments** - safe to update  
✅ **Can enable features later** - flexible adoption  

---

## 📚 Related Documentation

- **Terraform Version:** See `NEW-FEATURES.md` for Terraform module documentation
- **Best Practices:** See `RECOMMENDATIONS.md` for comprehensive guidance
- **Integration Guide:** See `INTEGRATION-GUIDE.md` for migration steps
- **Architecture:** See `ARCHITECTURE.md` for visual diagrams

---

## 🆘 Troubleshooting

### Issue: Backup deployment fails

**Solution:** Ensure Microsoft.RecoveryServices provider is registered:
```bash
az provider register --namespace Microsoft.RecoveryServices
az provider show --namespace Microsoft.RecoveryServices
```

### Issue: Policy assignment fails with permission error

**Solution:** Ensure deploying user has "Resource Policy Contributor" role:
```bash
az role assignment create \
  --assignee <user-id> \
  --role "Resource Policy Contributor" \
  --scope "/subscriptions/<subscription-id>/resourceGroups/<rg-name>"
```

### Issue: Image Gallery name contains invalid characters

**Solution:** Gallery names can only contain alphanumeric and underscores. The template automatically converts hyphens to underscores.

---

## 🎉 Summary

Your ARM template now offers enterprise-grade optional features:

| Feature | Benefit | Cost | Recommended For |
|---------|---------|------|-----------------|
| **Backup** | Disaster recovery | $10-30/VM | Production |
| **Image Gallery** | Standardization | $5/month | Enterprise |
| **Policies** | Governance | FREE | Everyone |

**All features are opt-in** - enable only what you need!

**Deploy now:** Use the Deploy to Azure button in README.md
