# Todo Application Project Manual

## Table of Contents

1. [Introduction](#introduction)
2. [Project Overview](#project-overview)
3. [Setting Up Your Development Environment](#setting-up-your-development-environment)
   - [Windows Setup](#windows-setup)
   - [Mac Setup](#mac-setup)
   - [Linux Setup](#linux-setup)
4. [Running the Application Locally](#running-the-application-locally)
5. [Understanding the Application Architecture](#understanding-the-application-architecture)
6. [Database Configuration](#database-configuration)
7. [Deploying to Azure Cloud](#deploying-to-azure-cloud)
8. [Monitoring and Maintenance](#monitoring-and-maintenance)
9. [Troubleshooting](#troubleshooting)
10. [Glossary](#glossary)

## Introduction

This manual provides comprehensive instructions for understanding, setting up, running, and deploying the Todo Application. This application is built using R Shiny, a web application framework for R that makes it easy to build interactive web applications straight from R.

Whether you're a developer, system administrator, or business user, this manual will guide you through all necessary steps to work with the application.

## Project Overview

The Todo Application is a sample enterprise-level Shiny application that demonstrates best practices for building scalable and maintainable web applications using R. It implements a simple task management system with the following features:

- Task creation, viewing, updating, and deletion (CRUD operations)
- Custom styling for a professional look and feel
- Modular architecture for improved code organization
- Custom event handling for enhanced user interaction
- Database integration for persistent storage
- Comprehensive testing

Unlike typical R Shiny applications that only handle data in memory, this application incorporates a custom data layer that enables persistent storage, making it more suitable for enterprise environments.

## Setting Up Your Development Environment

This section guides you through setting up your development environment. The setup process varies slightly depending on your operating system.

### Prerequisites

Before you begin, ensure you have the following installed:
- R (version 4.0.0 or higher)
- RStudio (recommended) or Visual Studio Code with R extension
- Git

### Windows Setup

1. **Install R**:
   - Download R from [CRAN](https://cran.r-project.org/bin/windows/base/)
   - Run the installer and follow the on-screen instructions

2. **Install RStudio**:
   - Download RStudio from [RStudio's website](https://www.rstudio.com/products/rstudio/download/)
   - Run the installer and follow the on-screen instructions

3. **Install Git**:
   - Download Git from [Git's website](https://git-scm.com/download/win)
   - Run the installer and accept the default settings

4. **Install Required Packages**:
   - Open RStudio
   - Run the following commands in the console:

   ```r
   install.packages("devtools")
   install.packages("shiny")
   install.packages("shinydashboard")
   install.packages("dplyr")
   install.packages("DT")
   install.packages("shinytest2")
   install.packages("uuid")
   ```

5. **Install GitHub Packages**:
   - Run the following commands in the RStudio console:

   ```r
   devtools::install_github("https://github.com/FlippieCoetser/Validate")
   devtools::install_github("https://github.com/FlippieCoetser/Environment")
   devtools::install_github("https://github.com/FlippieCoetser/Query")
   devtools::install_github("https://github.com/FlippieCoetser/Storage")
   ```

6. **Set Up ODBC Driver (for database connection)**:
   - Download and install the [Microsoft ODBC Driver 18 for SQL Server](https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
   - Open "ODBC Data Sources (64-bit)" from Windows search
   - Go to "User DSN" tab
   - Click "Add" and select "ODBC Driver 18 for SQL Server"
   - Configure with these parameters:
     - Name: Shiny
     - Server: shiny.database.windows.net,1433
     - Database: Shiny
     - Authentication: SQL Server authentication
     - Username and password: (ask your administrator)

7. **Clone the Repository**:
   - Open Command Prompt
   - Navigate to the directory where you want to store the project
   - Run:
   ```
   git clone https://github.com/FlippieCoetser/Shiny.Todo.git
   ```

### Mac Setup

1. **Install R**:
   - Download R from [CRAN](https://cran.r-project.org/bin/macosx/)
   - Run the installer and follow the on-screen instructions

2. **Install RStudio**:
   - Download RStudio from [RStudio's website](https://www.rstudio.com/products/rstudio/download/)
   - Drag the application to your Applications folder

3. **Install Git**:
   - If you don't have Git installed, open Terminal and run:
   ```
   xcode-select --install
   ```

4. **Install Required Packages and Clone Repository**:
   - Follow the same steps as in the Windows setup from step 4 onwards

### Linux Setup

1. **Install R**:
   - For Ubuntu/Debian:
   ```
   sudo apt-get update
   sudo apt-get install r-base r-base-dev
   ```
   - For Fedora/CentOS/RHEL:
   ```
   sudo yum install R
   ```

2. **Install RStudio**:
   - Download the appropriate package from [RStudio's website](https://www.rstudio.com/products/rstudio/download/)
   - Install it using your package manager

3. **Install Git**:
   - For Ubuntu/Debian:
   ```
   sudo apt-get install git
   ```
   - For Fedora/CentOS/RHEL:
   ```
   sudo yum install git
   ```

4. **Install Required Packages and Clone Repository**:
   - Follow the same steps as in the Windows setup from step 4 onwards

## Running the Application Locally

After setting up your development environment, follow these steps to run the application locally:

1. **Open RStudio**

2. **Set Working Directory**:
   - Navigate to the cloned repository folder
   - In RStudio, use the "Session" menu > "Set Working Directory" > "Choose Directory"
   - Or use the console:
   ```r
   setwd("path/to/Shiny.Todo")
   ```

3. **Load the Data**:
   - In the RStudio console, run:
   ```r
   devtools::load_all()
   ```
   - This loads all the functions and mock data from the package

4. **Load the Shiny Package**:
   ```r
   library(shiny)
   ```

5. **Run the Application**:
   ```r
   runApp()
   ```

6. **Interact with the Application**:
   - The application should open in a new window or your default web browser
   - You can create, view, update, and delete tasks

## Understanding the Application Architecture

The Todo Application follows a three-layer architecture typical in enterprise software development:

### User Interface (UI) Layer

The UI layer is responsible for the look and feel of the application. In this application, the UI is defined in the `ui.R` file and uses the `shinydashboard` package for layout.

Key components:
- Dashboard header with the application title
- Main body containing the Todo view
- Custom styling to enhance appearance

### Business Logic (BL) Layer

The Business Logic layer handles the application's logic and is defined in the `server.R` file. It processes user inputs, performs operations on data, and updates the UI accordingly.

Key components:
- Input event handling
- Data validation
- State management using reactive values
- Output binding to update the UI

### Data Layer

The Data layer manages data persistence. Unlike typical Shiny applications that only work with in-memory data, this application includes a custom data layer for CRUD operations.

Key components:
- Data broker for database operations
- Service layer for business rules
- Validation for data integrity
- Exception handling for robust error management

### Modular Design

The application implements a modular design with:
- `Todo.View`: UI component for the Todo functionality
- `Todo.Controller`: Business logic for the Todo functionality
- These modules work together to create a reusable, maintainable component

## Database Configuration

The application is designed to work with Microsoft SQL Server through ODBC connections.

### Local Development Configuration

For local development, the application uses a mock in-memory database by default. If you want to connect to a real database:

1. Ensure the ODBC driver is installed (see Setup sections)
2. Configure your DSN as described in the setup section
3. Update the connection string in your application code

### Production Database Configuration

For production deployment, the application connects to a SQL Server database using environment variables set in the container or App Service:

- DRIVER: ODBC Driver 18 for SQL Server
- SERVER: Your database server address
- DATABASE: Your database name
- UID: Database username
- PWD: Database password

These credentials are stored securely in Azure Key Vault when deployed to Azure.

## Deploying to Azure Cloud

The application can be deployed to Azure using Docker containers and Azure App Service. This section provides a step-by-step guide for deployment.

### Prerequisites for Deployment

- Azure subscription
- Azure CLI installed
- Docker installed
- GitHub account with access to the repository
- Bash shell environment (Git Bash, WSL, or a Linux/Mac terminal)

### Deployment Steps

#### 1. Set Up Azure Infrastructure

1. **Clone the Repository** (if not already done):
   ```bash
   git clone https://github.com/FlippieCoetser/Shiny.Todo.git
   cd Shiny.Todo
   ```

2. **Run the Setup Script**:
   ```bash
   # Run from bash terminal or WSL
   ./scripts/setup-azure.sh
   ```

   This script creates:
   - Resource Group
   - Azure Container Registry (ACR)
   - App Service Plan
   - Web App configured for containers
   - Azure AD App Registration
   - Key Vault for secrets
   - Managed Identity for the Web App

3. **Note the Credentials**:
   The script will output credentials needed for GitHub Actions. Save these for the next step.

#### 2. Configure GitHub Secrets

1. **Go to Your GitHub Repository**
2. **Navigate to Settings > Secrets and Variables > Actions**
3. **Add the Following Secrets**:
   - `AZURE_CREDENTIALS`: JSON credentials from the setup script
   - `AZURE_TENANT_ID`: Your Azure tenant ID
   - `AAD_CLIENT_ID`: Azure AD application client ID
   - `GITHUB1_PAT` and `GITHUB2_PAT`: GitHub Personal Access Tokens for private package access

#### 3. Build and Push the Docker Image

1. **Manually Trigger the Build Workflow**:
   - Go to the Actions tab in your GitHub repository
   - Select the "Build and Push Docker Image" workflow
   - Click "Run workflow"
   - Select the branch (usually main)
   - Click "Run workflow" again

   This workflow:
   - Logs in to Azure
   - Builds the Docker image with your GitHub PATs
   - Pushes the image to Azure Container Registry

#### 4. Deploy the Application

1. **Trigger the Deploy Workflow**:
   - You can either:
     - Push a change to the main branch (excluding certain files)
     - Manually trigger the "Deploy RShiny App" workflow from the Actions tab

   This workflow:
   - Updates container settings for the App Service
   - Configures Key Vault references
   - Sets up Azure AD Authentication
   - Restarts the App Service
   - Verifies the deployment

2. **Access Your Application**:
   After deployment, the application will be available at:
   `https://shiny-web-app.azurewebsites.net`

### Alternative: Manual Deployment

If you prefer to deploy manually:

1. **Build the Docker Image Locally**:
   ```bash
   docker build --build-arg GITHUB1_PAT=your_pat_here --build-arg GITHUB2_PAT=your_other_pat_here -t todo-app:latest .
   ```

2. **Push the Image to ACR**:
   ```bash
   az acr login --name rshinycr
   docker tag todo-app:latest rshinycr.azurecr.io/todo-app:latest
   docker push rshinycr.azurecr.io/todo-app:latest
   ```

3. **Update the App Service**:
   ```bash
   az webapp config container set --name shiny-web-app --resource-group r-shiny-rg --docker-custom-image-name rshinycr.azurecr.io/todo-app:latest
   ```

### Cleanup

When you're done with the environment, you can remove all resources:

```bash
./scripts/cleanup-azure.sh
```

## Monitoring and Maintenance

### Monitoring Your Application

Once deployed, monitor your application using:

1. **Azure Portal**:
   - Navigate to your App Service
   - Check the "Monitoring" section for logs and metrics
   - Use "Log stream" to see real-time logs

2. **Application Insights** (if configured):
   - View detailed performance metrics
   - Track exceptions and failures
   - Monitor user behavior

3. **Azure Container Registry**:
   - Manage container images
   - Check image versions and tags

### Updating the Application

To update your application:

1. **Make Code Changes**:
   - Edit the application code in your local environment
   - Test the changes locally

2. **Commit and Push**:
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin main
   ```

3. **Deployment**:
   - For UI or logic changes, the deploy workflow will automatically trigger
   - For Dockerfile changes, manually trigger the build workflow first

## Troubleshooting

### Common Issues and Solutions

#### Local Development Issues

1. **Package Installation Errors**:
   - Make sure you have an internet connection
   - Check if you have the correct permissions
   - Try installing packages one by one to identify problematic ones

2. **Application Won't Start**:
   - Check if all required packages are installed
   - Verify your working directory is correct
   - Look for error messages in the R console

3. **Database Connection Issues**:
   - Verify ODBC driver installation
   - Check DSN configuration
   - Test connection separately using `odbcConnect` function

#### Deployment Issues

1. **Docker Build Failures**:
   - Check GitHub PAT validity
   - Look for package installation errors in the build logs
   - Verify Dockerfile syntax

2. **Azure Deployment Failures**:
   - Check Azure credentials and permissions
   - Verify resource names and configuration
   - Review deployment logs in GitHub Actions

3. **Application Not Accessible**:
   - Check if the App Service is running
   - Verify network configuration and firewalls
   - Check authentication settings

### Getting Help

If you encounter issues not covered in this manual:

1. Check the GitHub repository issues section
2. Review the R Shiny documentation
3. Consult with your development team or IT support

## Glossary

- **Shiny**: An R package that makes it easy to build interactive web apps straight from R
- **R**: A programming language for statistical computing and graphics
- **CRUD**: Create, Read, Update, Delete - the four basic operations of persistent storage
- **UI**: User Interface - what the user sees and interacts with
- **BL**: Business Logic - the rules and processes that handle data
- **Azure**: Microsoft's cloud computing platform
- **ACR**: Azure Container Registry - a service to store and manage container images
- **App Service**: Azure's platform for hosting web applications
- **Docker**: A platform for developing, shipping, and running applications in containers
- **ODBC**: Open Database Connectivity - a standard API for accessing database management systems
- **DSN**: Data Source Name - a configuration used to connect to a database
- **GitHub Actions**: A CI/CD platform integrated with GitHub
- **CI/CD**: Continuous Integration/Continuous Deployment - automating the build, test, and deployment process
