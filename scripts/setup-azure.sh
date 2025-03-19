#!/bin/bash

# Set variables
RESOURCE_GROUP="r-shiny-rg"
LOCATION="eastus"
ACR_NAME="rshinycr"
SERVICE_PRINCIPAL_NAME="r-shiny-sp"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Container Registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Standard \
  --admin-enabled true

# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

# Get ACR admin credentials
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)

# Create service principal and assign permissions
SP_PASSWORD=$(az ad sp create-for-rbac \
  --name $SERVICE_PRINCIPAL_NAME \
  --role contributor \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP \
  --query password \
  --output tsv)

SP_APP_ID=$(az ad sp list \
  --display-name $SERVICE_PRINCIPAL_NAME \
  --query "[].appId" \
  --output tsv)

# Assign ACR permissions to service principal
az role assignment create \
  --assignee $SP_APP_ID \
  --role AcrPush \
  --scope /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME

# Output values to be added to GitHub Secrets
echo "Please add the following values to your GitHub repository Secrets:"
echo "AZURE_CREDENTIALS={"
 echo "  \"clientId\": \"$SP_APP_ID\","
 echo "  \"clientSecret\": \"$SP_PASSWORD\","
 echo "  \"subscriptionId\": \"$(az account show --query id -o tsv)\","
 echo "  \"tenantId\": \"$(az account show --query tenantId -o tsv)\""
 echo "}"
echo "ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER"
echo "ACR_USERNAME=$ACR_USERNAME"
echo "ACR_PASSWORD=$ACR_PASSWORD"
echo "RESOURCE_GROUP=$RESOURCE_GROUP"