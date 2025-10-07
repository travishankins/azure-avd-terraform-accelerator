#!/bin/bash

# Azure Virtual Desktop Deployment Script
# This script automates the deployment of the AVD environment using Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install Azure CLI first."
        exit 1
    fi
    
    # Check if logged into Azure
    if ! az account show &> /dev/null; then
        print_error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    print_success "Prerequisites check passed!"
}

# Function to register required resource providers
register_providers() {
    print_status "Registering Azure resource providers..."
    
    providers=(
        "Microsoft.DesktopVirtualization"
        "Microsoft.Storage"
        "Microsoft.KeyVault"
        "Microsoft.OperationalInsights"
        "Microsoft.Compute"
        "Microsoft.Network"
    )
    
    for provider in "${providers[@]}"; do
        print_status "Registering $provider..."
        az provider register --namespace "$provider" --wait
    done
    
    print_success "Resource providers registered successfully!"
}

# Function to initialize Terraform
terraform_init() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized successfully!"
}

# Function to validate Terraform configuration
terraform_validate() {
    print_status "Validating Terraform configuration..."
    terraform validate
    print_success "Terraform configuration is valid!"
}

# Function to plan Terraform deployment
terraform_plan() {
    print_status "Creating Terraform execution plan..."
    terraform plan -out=tfplan
    print_success "Terraform plan created successfully!"
}

# Function to apply Terraform deployment
terraform_apply() {
    print_status "Applying Terraform configuration..."
    terraform apply tfplan
    print_success "AVD environment deployed successfully!"
}

# Function to show deployment outputs
show_outputs() {
    print_status "Deployment completed! Here are the important outputs:"
    echo ""
    terraform output
    echo ""
    print_success "You can now assign users to the AVD application group and start using the environment!"
}

# Function to cleanup plan file
cleanup() {
    if [ -f "tfplan" ]; then
        rm tfplan
        print_status "Cleaned up temporary files."
    fi
}

# Main deployment function
deploy() {
    print_status "Starting Azure Virtual Desktop deployment..."
    echo ""
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars file not found!"
        print_status "Please copy terraform.tfvars.example to terraform.tfvars and customize the values."
        print_status "Example: cp terraform.tfvars.example terraform.tfvars"
        exit 1
    fi
    
    check_prerequisites
    register_providers
    terraform_init
    terraform_validate
    terraform_plan
    
    # Ask for confirmation before applying
    echo ""
    print_warning "This will create Azure resources that may incur costs."
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform_apply
        show_outputs
    else
        print_status "Deployment cancelled by user."
        cleanup
        exit 0
    fi
    
    cleanup
}

# Function to destroy the environment
destroy() {
    print_warning "This will destroy the entire AVD environment!"
    print_warning "All session hosts, user data, and configurations will be permanently deleted."
    echo ""
    read -p "Are you sure you want to destroy the environment? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Destroying AVD environment..."
        terraform destroy
        print_success "AVD environment destroyed successfully!"
    else
        print_status "Destroy operation cancelled by user."
    fi
}

# Function to show help
show_help() {
    echo "Azure Virtual Desktop Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    Deploy the AVD environment (default)"
    echo "  destroy   Destroy the AVD environment"
    echo "  plan      Show the Terraform execution plan"
    echo "  output    Show deployment outputs"
    echo "  help      Show this help message"
    echo ""
    echo "Prerequisites:"
    echo "  - Terraform >= 1.0"
    echo "  - Azure CLI"
    echo "  - Azure subscription with appropriate permissions"
    echo "  - terraform.tfvars file with your configuration"
    echo ""
}

# Function to show plan only
plan_only() {
    check_prerequisites
    terraform_init
    terraform_validate
    terraform plan
}

# Function to show outputs only
output_only() {
    terraform output
}

# Main script logic
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    destroy)
        destroy
        ;;
    plan)
        plan_only
        ;;
    output)
        output_only
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac