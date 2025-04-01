#!/bin/bash
set -e

# setting up variables
RESOURCE_GROUP="r-shiny-rg"
LOCATION="eastus"
ACR_NAME="rshinycr"
APP_SERVICE_NAME="r-shiny-app"
APP_SERVICE_PLAN="r-shiny-plan"
SERVICE_PRINCIPAL_NAME="r-shiny-sp"

# create resource group
echo "Creating resource group: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION

# create Azure Container Registry
echo "Creating Azure Container Registry: $ACR_NAME"
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Standard \
  --admin-enabled true

# get ACR credentials
ACR_USERNAME=$(az acr credential show -n $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show -n $ACR_NAME --query passwords[0].value -o tsv)
ACR_LOGIN_SERVER=$(az acr show -n $ACR_NAME --query loginServer -o tsv)

# create service principal for GitHub Actions access
echo "Creating service principal: $SERVICE_PRINCIPAL_NAME"
SP_JSON=$(az ad sp create-for-rbac \
  --name $SERVICE_PRINCIPAL_NAME \
  --role contributor \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth)

# output values to be added to GitHub Secrets
echo ""
echo "============= GitHub Secrets ============="
echo "Please add the following secrets to your GitHub repository:"
echo ""
echo "RESOURCE_GROUP=$RESOURCE_GROUP"
echo "APP_SERVICE_NAME=$APP_SERVICE_NAME"
echo "ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER"
echo "ACR_USERNAME=$ACR_USERNAME"
echo "ACR_PASSWORD=$ACR_PASSWORD"
echo "AZURE_CREDENTIALS=$SP_JSON"
echo ""
echo "==========================================="
