# Deploy to Azure Wizard - Updated Flow

## 🎨 New Wizard Experience

The **Deploy to Azure** wizard now includes a new step for production features!

---

## 📋 Wizard Steps Overview

### Before (6 Steps)
```
1. Basics (Resource prefix, Environment)
2. Identity Configuration (Azure AD / Domain Services)
3. Network Configuration (New / Existing VNet)
4. Session Hosts (VM count, size, credentials)
5. Host Pool (Type, load balancing)
6. Tags
```

### After (7 Steps) ⭐
```
1. Basics (Resource prefix, Environment)
2. Identity Configuration (Azure AD / Domain Services)
3. Network Configuration (New / Existing VNet)
4. Session Hosts (VM count, size, credentials)
5. Host Pool (Type, load balancing)
6. Production Features (NEW!) ⭐
   ├─ Azure Backup (optional)
   ├─ Shared Image Gallery (optional)
   └─ Azure Policy (optional)
7. Tags
```

---

## 🎯 Step 6: Production Features (Detailed View)

### Page Title
**"Production Features (Optional)"**

### Information Box
```
ℹ️ These optional features enhance your deployment with enterprise 
   capabilities: Backup provides disaster recovery, Image Gallery 
   enables golden images, and Policies enforce governance. All 
   features are optional and can be enabled later.
```

---

### Section 1: Azure Backup

**Checkbox:**
```
☐ Enable Azure Backup for session hosts
```

**Tooltip:**
> Automatically backup session host VMs for disaster recovery. Recommended for production environments.

**When Checked - Shows:**

**Information Box:**
```
ℹ️ Backup will create a Recovery Services Vault and automatically 
   protect all session hosts. Daily backups run at 2:00 AM UTC. 
   Estimated cost: $10-30 per VM per month.
```

**Slider:**
```
Daily Backup Retention (days)
[━━━━━━━━━━━━━━━━━━━━━] 30
7                           180
```

---

### Section 2: Shared Image Gallery

**Checkbox:**
```
☐ Enable Shared Image Gallery for golden images
```

**Tooltip:**
> Create a gallery to store and version custom VM images. Recommended for standardized deployments.

**When Checked - Shows:**

**Information Box:**
```
ℹ️ Image Gallery will be created with Windows 11 Multi-Session 
   definition. Build custom images later using Azure Image Builder 
   or manually. Use golden images to deploy session hosts with 
   pre-installed applications and configurations. Estimated cost: 
   $5 per month.
```

---

### Section 3: Azure Policy Governance

**Checkbox:**
```
☐ Enable Azure Policy for governance and compliance
```

**Tooltip:**
> Apply governance policies to enforce standards. Policies are free and highly recommended.

**When Checked - Shows:**

**Information Box:**
```
ℹ️ The following policies will be applied: Require Managed Disks, 
   Restrict VM Sizes, Require Environment Tag. These policies help 
   maintain compliance and prevent configuration drift. No 
   additional cost.
```

**Multi-Select Dropdown:**
```
Allowed VM Sizes
┌─────────────────────────────────────────┐
│ Filter sizes...                     🔍   │
├─────────────────────────────────────────┤
│ ☑ Standard_D2s_v5 (2 vCPU, 8 GB)       │
│ ☑ Standard_D4s_v5 (4 vCPU, 16 GB)      │
│ ☑ Standard_D8s_v5 (8 vCPU, 32 GB)      │
│ ☑ Standard_D16s_v5 (16 vCPU, 64 GB)    │
│ ☐ Standard_D2ds_v5 (2 vCPU, 8 GB)      │
│ ☐ Standard_D4ds_v5 (4 vCPU, 16 GB)     │
│ ☐ Standard_D8ds_v5 (8 vCPU, 32 GB)     │
│ ☐ Standard_D16ds_v5 (16 vCPU, 64 GB)   │
└─────────────────────────────────────────┘
Select All | Deselect All
```

---

## 🎨 Visual Mockup

### Production Features Step (All Sections Expanded)

```
╔══════════════════════════════════════════════════════════════╗
║  Production Features (Optional)                  Step 6 of 7 ║
╠══════════════════════════════════════════════════════════════╣
║                                                                ║
║  ℹ️ These optional features enhance your deployment with      ║
║     enterprise capabilities...                                ║
║                                                                ║
║  ┌─ Azure Backup ────────────────────────────────────────┐   ║
║  │                                                         │   ║
║  │  ☑ Enable Azure Backup for session hosts              │   ║
║  │                                                         │   ║
║  │  ℹ️ Backup will create a Recovery Services Vault...   │   ║
║  │                                                         │   ║
║  │  Daily Backup Retention (days)                         │   ║
║  │  [━━━━━━━━━━━━━━━━━━━━━] 30                          │   ║
║  │  7                           180                        │   ║
║  │                                                         │   ║
║  └─────────────────────────────────────────────────────────┘   ║
║                                                                ║
║  ┌─ Shared Image Gallery ─────────────────────────────────┐   ║
║  │                                                         │   ║
║  │  ☑ Enable Shared Image Gallery for golden images      │   ║
║  │                                                         │   ║
║  │  ℹ️ Image Gallery will be created with Windows 11...  │   ║
║  │                                                         │   ║
║  └─────────────────────────────────────────────────────────┘   ║
║                                                                ║
║  ┌─ Azure Policy Governance ──────────────────────────────┐   ║
║  │                                                         │   ║
║  │  ☑ Enable Azure Policy for governance and compliance  │   ║
║  │                                                         │   ║
║  │  ℹ️ The following policies will be applied...         │   ║
║  │                                                         │   ║
║  │  Allowed VM Sizes                                      │   ║
║  │  ┌───────────────────────────────────────┐            │   ║
║  │  │ Filter sizes...                   🔍  │            │   ║
║  │  ├───────────────────────────────────────┤            │   ║
║  │  │ ☑ Standard_D2s_v5 (2 vCPU, 8 GB)    │            │   ║
║  │  │ ☑ Standard_D4s_v5 (4 vCPU, 16 GB)   │            │   ║
║  │  │ ☑ Standard_D8s_v5 (8 vCPU, 32 GB)   │            │   ║
║  │  │ ☑ Standard_D16s_v5 (16 vCPU, 64 GB) │            │   ║
║  │  └───────────────────────────────────────┘            │   ║
║  │  4 of 8 selected                                       │   ║
║  │                                                         │   ║
║  └─────────────────────────────────────────────────────────┘   ║
║                                                                ║
║                                           [Previous]  [Next >] ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📊 Configuration Presets

To help users, we could show example configurations:

### Preset 1: Development/Test
```
☐ Backup
☐ Image Gallery  
☐ Policies
```
**Estimated Cost:** Baseline only

### Preset 2: Standard Production
```
☑ Backup (30 days)
☐ Image Gallery
☑ Policies
```
**Estimated Cost:** Baseline + $50-150/month

### Preset 3: Enterprise
```
☑ Backup (90 days)
☑ Image Gallery
☑ Policies
```
**Estimated Cost:** Baseline + $60-170/month

---

## 🎯 User Journey Examples

### Journey 1: Cautious First-Timer
**Goal:** Test AVD without extra costs

**Steps:**
1. Click Deploy to Azure
2. Fill basics (avd-test, dev)
3. Choose Azure AD Join
4. Create new VNet
5. Deploy 2 small VMs
6. **Production Features:** Leave all unchecked ⭐
7. Add tags, deploy

**Outcome:** Basic AVD environment, lowest cost

---

### Journey 2: Production-Ready Deployment
**Goal:** Deploy enterprise-ready AVD

**Steps:**
1. Click Deploy to Azure
2. Fill basics (avd-prod, prod)
3. Choose Domain Services Join
4. Use existing VNet
5. Deploy 10 VMs (Standard_D4s_v5)
6. **Production Features:** ⭐
   - ✅ Enable Backup (60 days)
   - ✅ Enable Image Gallery
   - ✅ Enable Policies (restrict to D-series)
7. Add comprehensive tags, deploy

**Outcome:** Full enterprise deployment with governance

---

### Journey 3: Gradual Adoption
**Goal:** Start basic, add features later

**Initial Deployment:**
- Production Features: All unchecked

**Later (Week 2) - Redeploy:**
- Production Features:
  - ✅ Enable Backup
  - ☐ Image Gallery (not yet)
  - ✅ Enable Policies

**Later (Week 4) - Redeploy Again:**
- Production Features:
  - ✅ Enable Backup
  - ✅ Enable Image Gallery ⭐ (now ready)
  - ✅ Enable Policies

**Outcome:** Incremental feature adoption

---

## 💡 Help Text & Tooltips

### Backup Section

**Checkbox Tooltip:**
> Automatically backup session host VMs for disaster recovery. Recommended for production environments.

**Retention Slider Tooltip:**
> Number of days to retain daily backups. Longer retention = higher cost. Recommended: 30 days for dev/test, 60-90 days for production.

---

### Image Gallery Section

**Checkbox Tooltip:**
> Create a gallery to store and version custom VM images. Recommended for standardized deployments.

**Info Box:**
> After deployment, use Azure Image Builder or manually generalize a VM to create your first golden image. Golden images speed up deployment and ensure consistency.

---

### Policy Section

**Checkbox Tooltip:**
> Apply governance policies to enforce standards. Policies are free and highly recommended.

**VM Sizes Dropdown Tooltip:**
> Select which VM sizes are allowed for deployment. Restricting sizes helps control costs and maintain consistency. You can modify this later in Azure Policy.

---

## ✅ Validation Rules

### Backup Section
- If enabled: Retention days must be 7-180
- Default: 30 days

### Image Gallery Section
- No validation needed
- Just enable/disable

### Policy Section
- If enabled: Must select at least 1 VM size
- Default: D2s_v5, D4s_v5, D8s_v5, D16s_v5 selected

---

## 🎨 UI/UX Best Practices Applied

### 1. Progressive Disclosure
- Info boxes only show when features are enabled
- Advanced options (like VM sizes) only appear when relevant

### 2. Clear Defaults
- All features disabled by default (safe, low cost)
- Sensible defaults when enabled (30 days retention, common VM sizes)

### 3. Cost Transparency
- Every feature shows estimated cost
- Users make informed decisions

### 4. Contextual Help
- Info boxes explain what each feature does
- Tooltips provide additional guidance
- Links to documentation

### 5. Flexibility
- All features are optional
- Can be enabled later via redeploy
- No lock-in

---

## 📱 Responsive Design

The wizard adapts to screen size:

**Desktop (1920x1080):**
- All sections visible
- Side-by-side layouts
- Full tooltips

**Tablet (1024x768):**
- Sections stack vertically
- Dropdown still multi-select
- Abbreviated tooltips

**Mobile (not recommended for deployment):**
- Basic form layout
- Single-column
- Portal recommends desktop

---

## 🔍 After Deployment

### Deployment Success Screen

```
✅ Deployment Complete!

Resources Created:
├─ Host Pool: avd-prod-hostpool
├─ Workspace: avd-prod-workspace  
├─ Session Hosts: 5 VMs
├─ Storage Account: avdprodstorage
├─ Log Analytics: avd-prod-law
├─ Key Vault: avd-prod-kv
│
└─ Production Features:
   ├─ ✅ Recovery Vault: avd-prod-rsv (5 VMs protected)
   ├─ ✅ Image Gallery: avd_prod_sig
   └─ ✅ Policies: 3 assignments active

Next Steps:
1. Access workspace at: https://client.wvd.microsoft.com
2. View backup jobs in Recovery Services Vault
3. Check policy compliance in Azure Policy
4. Build first golden image (optional)

Estimated Monthly Cost: $550-700
```

---

## 📚 Related Documentation

- **ARM Features Guide:** `ARM-NEW-FEATURES.md`
- **Terraform Version:** `NEW-FEATURES.md`
- **Best Practices:** `RECOMMENDATIONS.md`
- **Troubleshooting:** `INTEGRATION-GUIDE.md`

---

**Ready to deploy? Click the Deploy to Azure button in README.md!**
