# Azure Virtual Desktop (AVD) - Complete Environment Deployment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftravishankins%2Fazure-avd-terraform-accelerator%2Fmain%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Ftravishankins%2Fazure-avd-terraform-accelerator%2Fmain%2FcreateUiDefinition.json)

This project deploys a complete Azure Virtual Desktop environment using a modular architecture following Azure best practices. The infrastructure is organized into logical modules for better maintainability, reusability, and management.

## 🚀 Quick Start

### Option 1: Deploy via Azure Portal (Recommended for Quick Start)
Click the **Deploy to Azure** button above to launch the deployment wizard in Azure Portal. The wizard will guide you through:
- Basic configuration (resource prefix, location, environment)
- Identity settings (Azure AD or Domain Services join)
- Network configuration (new or existing VNet)
- Session host settings (VM size, count, image)
- Host pool configuration (type, load balancing, RDP properties)
- **Production features** (Backup, Image Gallery, Azure Policy) - Optional
- Tags and metadata

### Option 2: Deploy via Terraform (Advanced Users)
Clone this repository and customize the deployment using Terraform for full control over all settings.

## 🏗️ Architecture Overview

The deployment creates the following resources:

### Core AVD Components
- **Host Pool**: Manages the collection of session hosts
- **Application Group**: Desktop application group for user access
- **Workspace**: User-facing workspace for AVD access
- **Session Hosts**: Windows 11 multi-session VMs

### Supporting Infrastructure
- **Virtual Network**: Isolated network with dedicated subnet for AVD
- **Network Security Group**: Security rules for AVD traffic
- **Storage Account**: Premium file storage for FSLogix profiles
- **Key Vault**: Secure storage for credentials and secrets
- **Log Analytics Workspace**: Monitoring and logging for AVD

### Security & Monitoring
- **Azure Monitor**: Diagnostic settings and metrics collection
- **Azure AD Integration**: Azure AD joined session hosts
- **Encrypted Storage**: Premium file storage with Azure AD Kerberos authentication

## 📋 Prerequisites

Before deploying this AVD environment, ensure you have:

1. **Azure Subscription** with sufficient permissions:
   - Contributor or Owner role on the subscription
   - Global Administrator or Privileged Role Administrator in Azure AD

2. **Terraform** installed (version >= 1.0)
   - [Download Terraform](https://www.terraform.io/downloads.html)

3. **Azure CLI** installed and configured
   - [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
   - Run `az login` to authenticate

4. **Required Azure Resource Providers** registered:
   ```bash
   az provider register --namespace Microsoft.DesktopVirtualization
   az provider register --namespace Microsoft.Storage
   az provider register --namespace Microsoft.KeyVault
   az provider register --namespace Microsoft.OperationalInsights
   az provider register --namespace Microsoft.Compute
   az provider register --namespace Microsoft.Network
   ```

## 🚀 Quick Start

### 1. Clone and Configure

```bash
# Clone this repository (or copy the files to your local directory)
cd avd-accelator-avm

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars
```

### 2. Customize Variables

Edit `terraform.tfvars` with your specific values:

```hcl
resource_prefix = "mycompany-avd"
location        = "East US"
environment     = "prod"

# Update with your corporate network CIDR
corporate_network_cidr = "203.0.113.0/24"

# Customize session host configuration
session_host_count = 5
vm_sku_size        = "Standard_D4s_v5"

# Configure tags for your organization
tags = {
  Owner        = "IT Department"
  CostCenter   = "12345"
  Application  = "Azure Virtual Desktop"
  Project      = "AVD Migration"
}
```

### 3. Deploy the Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Deploy the infrastructure
terraform apply
```

The deployment typically takes 15-20 minutes to complete.

### 4. Post-Deployment Configuration

After successful deployment:

1. **Assign Users to Application Group**:
   ```bash
   # Get the application group name from outputs
   APP_GROUP_NAME=$(terraform output -raw avd_application_group_name)
   
   # Assign users (replace with actual user principal names)
   az role assignment create \
     --role "Desktop Virtualization User" \
     --assignee "user@yourdomain.com" \
     --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$(terraform output -raw resource_group_name)/providers/Microsoft.DesktopVirtualization/applicationGroups/$APP_GROUP_NAME"
   ```

2. **Configure FSLogix** (if using profile containers):
   - Install FSLogix agent on session hosts
   - Configure registry settings for profile container path

3. **Install Applications**:
   - Connect to session hosts and install required applications
   - Create custom images for faster deployment (optional)

## 📁 File Structure

```
avd-accelator-avm/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example  # Example variables file
├── README.md                  # This file
└── scripts/                   # Optional: PowerShell scripts for post-deployment
```

## 🔧 Advanced Configuration

### 🌐 Networking Flexibility

The networking module supports both **creating new infrastructure** and **using existing** VNets/subnets:

#### **Option 1: Create New VNet and Subnet (Default)**
```hcl
# terraform.tfvars
use_existing_vnet = false
create_new_subnet = true
vnet_address_space = ["10.0.0.0/16"]
subnet_address_prefixes = ["10.0.1.0/24"]
```

#### **Option 2: Use Existing VNet, Create New Subnet**
```hcl
# terraform.tfvars
use_existing_vnet = true
existing_vnet_name = "my-company-vnet"
existing_vnet_resource_group = "network-rg"
create_new_subnet = true
subnet_address_prefixes = ["10.0.5.0/24"]  # Available range in existing VNet
```

#### **Option 3: Use Existing VNet and Existing Subnet**
```hcl
# terraform.tfvars
use_existing_vnet = true
existing_vnet_name = "my-company-vnet"
existing_vnet_resource_group = "network-rg"
create_new_subnet = false
existing_subnet_name = "avd-subnet"
```

### 🛡️ Security Considerations for Existing Networks
- NSG rules will be applied to the specified subnet
- Ensure the existing subnet has adequate address space
- Review existing NSG rules for conflicts
- Consider network peering requirements if using existing VNets

### 🔑 Identity and Domain Join Options

The deployment supports **two identity join methods** for session hosts:

#### **Option 1: Azure AD Join (Cloud-Native) - Recommended**
```hcl
# terraform.tfvars
domain_join_option = "AzureAD"
```

**Benefits:**
- ✅ Cloud-native identity management
- ✅ Conditional Access support
- ✅ Windows Hello for Business
- ✅ Self-service password reset
- ✅ No on-premises infrastructure required
- ✅ Simplified management

**Requirements:**
- Azure AD tenant
- Users sign in with Azure AD credentials (user@domain.com)
- Azure AD Premium P1 or P2 recommended for Conditional Access

**Best For:**
- New AVD deployments
- Cloud-first organizations
- Modern authentication requirements

---

#### **Option 2: Active Directory Domain Services Join (Traditional AD)**
```hcl
# terraform.tfvars
domain_join_option     = "DomainServices"
domain_fqdn            = "contoso.com"
domain_join_username   = "domainadmin"
domain_join_password   = "SecurePassword123!"  # Store in Key Vault or use env variable
domain_ou_path         = "OU=AVD,DC=contoso,DC=com"  # Optional
```

**Benefits:**
- ✅ Supports legacy applications requiring AD authentication
- ✅ Group Policy management
- ✅ Traditional AD group-based access control
- ✅ Integration with existing on-premises infrastructure

**Requirements:**
- Active Directory Domain Services (on-premises or Azure AD DS)
- Network connectivity between AVD VNet and domain controllers
- DNS configured to resolve domain names
- Domain account with computer join permissions
- **Recommended:** Use Azure VPN/ExpressRoute for hybrid connectivity

**Network Configuration for Domain Join:**
```hcl
# Ensure network connectivity to domain controllers
use_existing_vnet              = true
existing_vnet_name             = "hub-vnet"  # VNet with DC connectivity
existing_vnet_resource_group   = "network-rg"
create_new_subnet              = false
existing_subnet_name           = "avd-subnet"

# Update DNS settings on the VNet to point to domain controllers
# az network vnet update --name hub-vnet --resource-group network-rg --dns-servers 10.0.0.4 10.0.0.5
```

**Best For:**
- Organizations with existing AD infrastructure
- Hybrid identity scenarios
- Applications requiring domain authentication
- Environments with Group Policy dependencies
---

### Session Host Configuration

The deployment supports various session host configurations:

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `session_host_count` | Number of session hosts | 2 | 1-100 |
| `vm_sku_size` | VM size for session hosts | Standard_D4s_v5 | D-series, E-series, F-series |
| `host_pool_type` | Host pool type | Pooled | Pooled, Personal |
| `host_pool_load_balancer_type` | Load balancing method | BreadthFirst | BreadthFirst, DepthFirst |

### Network Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `vnet_address_space` | Virtual network address space | ["10.0.0.0/16"] |
| `subnet_address_prefixes` | AVD subnet address prefixes | ["10.0.1.0/24"] |
| `corporate_network_cidr` | Corporate network CIDR for NSG | "0.0.0.0/0" |

### Storage Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `fslogix_storage_quota_gb` | FSLogix file share quota | 1024 GB |

## 🔐 Security Considerations

### Network Security
- Network Security Group restricts RDP access to corporate networks
- Session hosts are deployed in a dedicated subnet
- No public IP addresses assigned to session hosts

### Identity and Access
- Azure AD joined session hosts
- Admin credentials stored securely in Key Vault
- Role-based access control for AVD resources

### Storage Security
- Premium file storage with Azure AD Kerberos authentication
- Encrypted storage account for FSLogix profiles
- Private endpoints can be configured for additional security

### Monitoring and Compliance
- Azure Monitor integration for logging and metrics
- Diagnostic settings enabled for all AVD resources
- Log Analytics workspace for centralized logging

## 📊 Monitoring and Management

### Azure Monitor Integration
The deployment automatically configures:
- Diagnostic settings for AVD workspace and host pool
- Log Analytics workspace for centralized logging
- Metrics collection for performance monitoring

### Key Metrics to Monitor
- Session host CPU and memory utilization
- User session count and duration
- Connection success rates
- Storage performance for FSLogix profiles

### Recommended Alerts
Set up alerts for:
- High CPU utilization on session hosts
- Failed user connections
- Storage account throttling
- Session host availability

## 💰 Cost Optimization

### Auto-Shutdown
- Session hosts automatically shut down at 7 PM by default
- Customize shutdown time with `auto_shutdown_time` variable
- Reduces costs for development/test environments

### Right-Sizing
- Start with smaller VM sizes and scale up based on usage
- Monitor resource utilization and adjust accordingly
- Consider using Azure Reserved Instances for production workloads

### Storage Optimization
- Premium file storage provides better performance but higher cost
- Monitor FSLogix profile sizes and implement cleanup policies
- Consider using Azure Files lifecycle management

## 🔄 Maintenance and Updates

### Session Host Updates
- Use Azure Update Management for Windows updates
- Consider using custom images with pre-installed updates
- Schedule maintenance windows for minimal user impact

### Terraform State Management
- Store Terraform state in Azure Storage for team collaboration
- Enable state file versioning and backup
- Use Terraform Cloud or Azure DevOps for CI/CD pipelines

### Module Updates
- Regularly update Azure Verified Modules to latest versions
- Test updates in development environment first
- Review module changelogs for breaking changes

## 🆘 Troubleshooting

### Common Issues

1. **Session Host Registration Failures**:
   - Check Azure AD join status
   - Verify host pool registration token validity
   - Review session host event logs

2. **User Connection Issues**:
   - Verify user assignment to application group
   - Check network connectivity and NSG rules
   - Review conditional access policies

3. **FSLogix Profile Issues**:
   - Verify storage account permissions
   - Check Azure AD Kerberos authentication
   - Review FSLogix event logs on session hosts

### Diagnostic Commands

```bash
# Check deployment status
terraform show

# View outputs
terraform output

# Refresh state
terraform refresh

# Validate configuration
terraform validate
```

## 📞 Support and Resources

### Microsoft Documentation
- [Azure Virtual Desktop Documentation](https://docs.microsoft.com/en-us/azure/virtual-desktop/)
- [FSLogix Documentation](https://docs.microsoft.com/en-us/fslogix/)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)

### Terraform Resources
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### Community Support
- [Azure Virtual Desktop Tech Community](https://techcommunity.microsoft.com/t5/azure-virtual-desktop/bd-p/AzureVirtualDesktop)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core/27)

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

---

**Note**: This deployment creates Azure resources that incur costs. Make sure to review the pricing for each service and monitor your Azure spending. Use the auto-shutdown feature for development environments to minimize costs.