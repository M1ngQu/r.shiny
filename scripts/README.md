# Azure RShiny App Deployment with AAD Authentication

This repository contains a complete solution for deploying an R Shiny application to Azure with Azure Active Directory (AAD) authentication. The deployment utilizes container-based hosting, managed identities, and Azure Key Vault for secure secret management.

## 🌟 Features

- **Containerized Deployment**: R Shiny app packaged as a Docker container
- **Azure AD Authentication**: Secure access with Azure Active Directory
- **CI/CD Pipeline**: Automated deployment with GitHub Actions
- **Secret Management**: Secure handling of credentials using Azure Key Vault
- **Managed Identities**: Zero credential storage for secure Azure service access

## 📋 Prerequisites

Before you begin, ensure you have:

- Azure subscription with contributor access
- GitHub repository for your R Shiny application
- Docker installed (for local testing)
- Azure CLI installed (for initial setup)

## 🚀 Deployment Process

The deployment consists of two main parts:

1. **Initial Azure Setup** - One-time setup of required Azure resources
2. **CI/CD Pipeline** - Continuous deployment via GitHub Actions

### Step 1: Initial Azure Setup

The `setup-azure.sh` script automates the creation of all necessary Azure resources:

```bash
# Make the script executable
chmod +x setup-azure.sh

# Run the setup script
./setup-azure.sh
```

This script will create:
- Resource group
- Azure Container Registry (ACR)
- App Service Plan
- Web App for Containers
- Azure AD application registration
- Key Vault with necessary secrets
- Managed identity and permissions

The script outputs all required credentials for GitHub Actions setup.

### Step 2: Configure GitHub Repository

1. Navigate to your GitHub repository
2. Go to **Settings** > **Secrets and variables** > **Actions**
3. Add the following secrets from the setup script output:
   - `AZURE_CREDENTIALS`: Azure service principal credentials (JSON)
   - `AAD_CLIENT_ID`: Azure AD application client ID
   - `AZURE_TENANT_ID`: Your Azure tenant ID

### Step 3: Add GitHub Workflow File

Add the workflow file to your repository at `.github/workflows/main.yml`:

```yaml
# GitHub Actions workflow file content here (already in repo)
```

### Step 4: Prepare Your R Shiny Application

Ensure your R Shiny application repository includes:

1. **Dockerfile**: To containerize your Shiny application
2. **Application Code**: Your R Shiny application files
3. **Health Check Endpoint**: A simple endpoint that returns HTTP 200 to verify deployment


## 🔄 Deployment Flow

The complete deployment workflow:

1. Developer pushes code to the main branch
2. GitHub Actions workflow triggers automatically
3. Docker image is built and pushed to Azure Container Registry
4. App Service is updated to use the new container image
5. Key Vault references are configured in App Service settings
6. Azure AD authentication is configured
7. App Service is restarted to apply changes
8. Deployment verification confirms successful deployment

## 🛠️ Troubleshooting

Common issues and solutions:

### Authentication Issues
- Verify Azure AD app registration settings
- Check Key Vault access policies for managed identity
- Review App Service configuration for authentication settings

### Container Deployment Issues
- Check Docker build errors in GitHub Actions logs
- Verify ACR credentials and permissions
- Test Docker image locally before deployment

### Application Issues
- Review application logs in App Service
- Add debugging information to your Shiny app
- Test authentication flow locally with AAD credentials

## 📊 Monitoring and Management

Monitor your deployed application:

- **Application Logs**: Available in App Service monitoring section
- **Usage Statistics**: Monitor via Azure Application Insights
- **Authentication Events**: Track through Azure AD sign-in logs

## 🔐 Security Considerations

This deployment follows security best practices:

- No secrets in source code or environment variables
- Managed identities for service-to-service authentication
- Azure AD for user authentication and authorization
- Key Vault for centralized secret management
- Container security scanning and updates

## 🔄 Update Process

To update your application:

1. Make changes to your R Shiny code
2. Commit and push to GitHub
3. GitHub Actions automatically deploys the updated version
4. No manual intervention required

## 📚 Further Resources

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure AD Authentication](https://docs.microsoft.com/en-us/azure/active-directory/develop/)
- [R Shiny Server](https://www.rstudio.com/products/shiny/shiny-server/)
- [Docker Containers](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.