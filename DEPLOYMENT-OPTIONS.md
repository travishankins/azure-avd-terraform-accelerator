# AVD Deployment - Identity Join Options

## ✅ What's Been Updated

Your AVD deployment now supports **BOTH** Azure AD Join (cloud-native) and Active Directory Domain Services Join (traditional AD).

---

## 🎯 Quick Answer to Your Question

**"Are these VMs cloud joined or DC joined?"**

**Answer**: **You can choose!**

- **Default**: Azure AD Join (cloud-native) ☁️
- **Optional**: Active Directory Domain Services Join (traditional AD) 🏢
- Configurable in **both** Terraform and ARM deployments

---

## 📦 Files Updated on GitHub

### 1. **azuredeploy.json** ✅ Updated
ARM template with full domain join support:
- New parameters: `domainJoinOption`, `domainFqdn`, `domainJoinUsername`, `domainJoinPassword`, `ouPath`
- Conditional VM extensions based on join type
- Defaults to Azure AD join

### 2. **createUiDefinition.json** ✅ Updated  
Azure Portal wizard with new **Identity Configuration** step:
- Radio button to choose between Azure AD and Domain Services
- Conditional fields for domain credentials (only shown when Domain Services selected)
- Warning messages about network/DNS requirements
- Benefits info for each option

---

## 🚀 How to Use

### **Option 1: Azure AD Join (Recommended)**

#### Terraform:
```hcl
# terraform.tfvars
domain_join_option = "AzureAD"
# No additional config needed!
```

#### ARM Template / Deploy to Azure:
1. Click "Deploy to Azure" button
2. Step 1: Choose **"Azure AD Join (Recommended)"**
3. Complete remaining steps

**Requirements**:
- Azure AD tenant
- Users sign in with Azure AD credentials (user@domain.com)

**Benefits**:
- ✅ Cloud-native identity
- ✅ Conditional Access support
- ✅ Windows Hello for Business
- ✅ Self-service password reset
- ✅ No on-premises infrastructure

---

### **Option 2: Active Directory Domain Services Join**

#### Terraform:
```hcl
# terraform.tfvars
domain_join_option     = "DomainServices"
domain_fqdn            = "contoso.com"
domain_join_username   = "domainadmin"
domain_join_password   = "SecurePassword123!"  # Use Key Vault or env variable
domain_ou_path         = "OU=AVD,DC=contoso,DC=com"  # Optional

# IMPORTANT: Use existing VNet with DC connectivity
use_existing_vnet              = true
existing_vnet_name             = "hub-vnet"
existing_vnet_resource_group   = "network-rg"
create_new_subnet              = false
existing_subnet_name           = "avd-subnet"
```

#### ARM Template / Deploy to Azure:
1. Click "Deploy to Azure" button
2. Step 1: Choose **"Active Directory Domain Services Join"**
3. Fill in domain FQDN, username, password, OU path (optional)
4. Step 2: Select existing VNet with DC connectivity
5. Complete remaining steps

**Requirements**:
- Active Directory Domain Services (on-premises or Azure AD DS)
- Network connectivity to domain controllers (VPN/ExpressRoute)
- DNS configured to resolve domain names
- Domain account with computer join permissions

**Benefits**:
- ✅ Legacy app support requiring AD authentication
- ✅ Group Policy management
- ✅ Traditional AD group-based access
- ✅ Integration with existing on-prem infrastructure

---

## 📊 Comparison Table

| Feature | Azure AD Join | Domain Services Join |
|---------|---------------|---------------------|
| **Infrastructure** | Cloud-only ☁️ | Requires DCs 🏢 |
| **Network** | Minimal | DC Connectivity Required |
| **Conditional Access** | ✅ Full Support | ⚠️ Limited |
| **Group Policy** | ⚠️ Limited (Intune) | ✅ Full Support |
| **Legacy Apps** | ⚠️ Limited | ✅ Full Support |
| **Management** | ✅ Simple | ⚠️ More Complex |
| **Cost** | ✅ Lower | ⚠️ Higher (Network, DCs) |
| **Best For** | Modern, cloud-first | Legacy apps, Group Policy |

---

## 🔧 Technical Details

### What Gets Deployed (Azure AD Join):
1. VMs are created
2. **AADLoginForWindows** extension installed
3. DSC extension joins VMs to host pool with `aadJoin: true`
4. Users authenticate with Azure AD

### What Gets Deployed (Domain Services Join):
1. VMs are created
2. **JsonADDomainExtension** installed with domain credentials
3. VMs join the specified domain (with optional OU placement)
4. DSC extension joins VMs to host pool with `aadJoin: false`
5. Users authenticate with AD domain credentials

---

## ⚠️ Important Notes

### For Domain Services Join:
1. **DNS Configuration**: VNet DNS must point to domain controllers
   ```bash
   az network vnet update --name hub-vnet --resource-group network-rg \
     --dns-servers 10.0.0.4 10.0.0.5
   ```

2. **Network Connectivity**: VNet needs connectivity to DCs via:
   - Azure VPN Gateway
   - ExpressRoute
   - VNet peering to hub with DCs
   - Domain controllers in Azure

3. **Security**: Store domain credentials securely:
   - Use Azure Key Vault
   - Use environment variables
   - Never commit passwords to source control

---

## 🎉 What This Means for You

1. **Flexibility**: Choose the right identity solution for your needs
2. **Cloud-First Default**: Azure AD join by default for modern scenarios
3. **Hybrid Support**: Domain Services join for legacy/hybrid environments
4. **Easy Deployment**: Both options available in Terraform AND ARM templates
5. **Wizard Support**: Deploy to Azure button has full domain join configuration

---

## 📚 Documentation Updated

- ✅ README.md: Added full identity section with examples
- ✅ terraform.tfvars.example: Added domain join configuration examples
- ✅ ARM Template: Supports both join types
- ✅ UI Definition: Wizard with identity configuration step

---

## 🚦 Status

**All files uploaded to GitHub**: https://github.com/travishankins/azure-avd-terraform-accelerator

Ready to deploy! 🎯
