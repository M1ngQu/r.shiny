#!/bin/bash
set -e

# Set variables
RESOURCE_GROUP="r-shiny-rg"
ACR_NAME="rshinycr"
APP_SERVICE_NAME="r-shiny-app"
APP_SERVICE_PLAN="r-shiny-plan"
SERVICE_PRINCIPAL_NAME="r-shiny-sp"

echo "===== Starting Azure resource cleanup ====="

# Check and delete the service principal
echo "Checking service principal $SERVICE_PRINCIPAL_NAME..."
SP_APP_ID=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" -o tsv)
if [ -n "$SP_APP_ID" ]; then
    echo "Deleting service principal (AppId: $SP_APP_ID)..."
    az ad sp delete --id $SP_APP_ID
    echo "Service principal deleted."
else
    echo "Service principal $SERVICE_PRINCIPAL_NAME not found."
fi

# Check if the resource group exists
if az group show --name $RESOURCE_GROUP &>/dev/null; then
    echo "Listing resources to be deleted..."
    
    # Check App Service
    if az webapp show --name $APP_SERVICE_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
        echo "- App Service: $APP_SERVICE_NAME"
    else
        echo "- App Service $APP_SERVICE_NAME does not exist or has already been deleted."
    fi
    
    # Check App Service Plan
    if az appservice plan show --name $APP_SERVICE_PLAN --resource-group $RESOURCE_GROUP &>/dev/null; then
        echo "- App Service Plan: $APP_SERVICE_PLAN"
    else
        echo "- App Service Plan $APP_SERVICE_PLAN does not exist or has already been deleted."
    fi
    
    # Check Container Registry
    if az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
        echo "- Azure Container Registry: $ACR_NAME"
    else
        echo "- Azure Container Registry $ACR_NAME does not exist or has already been deleted."
    fi
    
    # Automatically confirm deletion of the resource group
    echo "Deleting resource group $RESOURCE_GROUP..."
    az group delete --name $RESOURCE_GROUP --yes --no-wait
    echo "Resource group deletion initiated. This may take a few minutes to complete."
else
    echo "Resource group $RESOURCE_GROUP does not exist or has already been deleted."
fi

echo "===== Cleanup operation completed ====="
echo "To recreate the environment, run the setup-azure.sh script."