#!/bin/bash

# Set variables (same as in setup-azure.sh)
RESOURCE_GROUP="r-shiny-rg"
ACR_NAME="rshinycr"
SERVICE_PRINCIPAL_NAME="r-shiny-sp"

# Save the latest image to local Docker (optional)
echo "Saving the latest image from ACR..."
LATEST_IMAGE=$(az acr repository show-tags -n $ACR_NAME --repository r-shiny --orderby time_desc --query "[0]" -o tsv)
if [ ! -z "$LATEST_IMAGE" ]; then
    docker pull $(az acr show --name $ACR_NAME --query loginServer -o tsv)/r-shiny:$LATEST_IMAGE
    docker tag $(az acr show --name $ACR_NAME --query loginServer -o tsv)/r-shiny:$LATEST_IMAGE r-shiny:latest
    echo "Latest image has been saved locally as r-shiny:latest"
fi

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
echo "The latest Docker image has been saved locally for future use."
echo "To rebuild the environment, just run setup-azure.sh again."