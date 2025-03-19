#!/bin/bash

# Set variables (same as in setup-azure.sh)
RESOURCE_GROUP="r-shiny-rg"
ACR_NAME="rshinycr"
SERVICE_PRINCIPAL_NAME="r-shiny-sp"

# Delete the service principal
echo "Deleting service principal..."
SP_APP_ID=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" -o tsv)
if [ ! -z "$SP_APP_ID" ]; then
    az ad sp delete --id $SP_APP_ID
fi

# Delete the resource group (this will delete ACR and all other resources in the group)
echo "Deleting resource group..."
az group delete --name $RESOURCE_GROUP --yes --no-wait

echo "Cleanup completed. All Azure resources are being deleted."
echo "To rebuild the environment, just run setup-azure.sh again."