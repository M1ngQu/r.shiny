# Azure CI/CD Deployment Guide

This guide will help you set up a CI/CD environment using Azure Container Registry (ACR) for deploying R Shiny applications.

## Prerequisites

1. Install Azure CLI
   ```bash
   # macOS
   brew install azure-cli
   
   # Windows
   # Download installer from https://aka.ms/installazurecliwindows
   
   # Linux
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. Login to Azure CLI
   ```bash
   az login
   ```

3. Ensure you have sufficient Azure permissions
   - Permission to create resource groups
   - Permission to create and manage ACR
   - Permission to create service principals

## Setting Up Azure Resources

1. Clone the repository and navigate to the scripts directory
   ```bash
   cd scripts
   ```

2. Add execution permissions to scripts
   ```bash
   chmod +x setup-azure.sh
   chmod +x cleanup-azure.sh
   ```

3. Run the setup-azure.sh script
   ```bash
   ./setup-azure.sh
   ```
   
   This script will:
   - Create a resource group
   - Create an Azure Container Registry
   - Create a service principal and configure necessary permissions
   - Output the required secrets for GitHub Actions

## Configuring GitHub Secrets

After the script runs, you need to add the output information to your GitHub repository's Secrets:

1. In your GitHub repository, go to Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Add the following secrets:
   - `AZURE_CREDENTIALS`: Complete JSON credentials (copy from script output)
   - `ACR_LOGIN_SERVER`: ACR login server address
   - `ACR_USERNAME`: ACR username
   - `ACR_PASSWORD`: ACR password
   - `RESOURCE_GROUP`: Name of the Azure resource group

## GitHub Actions Workflow Configuration

Create a workflow file (e.g., `deploy.yml`) in your repository's `.github/workflows` directory with the following steps:

1. Build Docker image
2. Push to Azure Container Registry
3. Deploy to target environment

## Cleaning Up Resources

To remove all created Azure resources:

```bash
./cleanup-azure.sh
```

This script will:
- Delete the service principal
- Delete the resource group (including ACR)

## Troubleshooting

1. If you encounter permission errors:
   - Verify that you're properly logged into Azure CLI
   - Confirm that your Azure account has sufficient permissions

2. If GitHub Actions fail:
   - Check if Secrets are correctly configured
   - Verify service principal permissions

3. If Docker push fails:
   - Verify ACR credentials
   - Check network connectivity

## Security Recommendations

1. Rotate ACR passwords regularly
2. Configure service principals with minimum required permissions
3. Never hardcode credentials in code
4. Review access permissions periodically

## Best Practices

1. Use version tags in production instead of the latest tag
2. Implement image scanning and security checks
3. Configure resource usage limits
4. Keep scripts and dependencies updated