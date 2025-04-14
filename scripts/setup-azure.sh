#!/bin/bash

# -------------------------------
# ⚙️ Configuration (Customizable)
# -------------------------------
RESOURCE_GROUP="r-shiny-rg"
LOCATION="australiasoutheast"

ACR_NAME="rshinycr" # Will append .azurecr.io
APP_SERVICE_PLAN="shiny-plan"
WEBAPP_NAME="shiny-web-app"

KEYVAULT_NAME="my-shiny-keyvault"
SECRET_NAME="aad-client-secret"

AAD_APP_NAME="shiny-ad-app"

# -------------------------------
# 🛠 Create Resource Group
# -------------------------------
echo "📁 Creating Resource Group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# -------------------------------
# 🐳 Create ACR
# -------------------------------
echo "🐳 Creating ACR: $ACR_NAME"
az acr create --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_NAME" \
  --sku Basic \
  --admin-enabled true

ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
echo "✅ ACR Login Server: $ACR_LOGIN_SERVER"

# -------------------------------
# 🧱 Create App Service Plan (Linux)
# -------------------------------
echo "🧱 Creating App Service Plan: $APP_SERVICE_PLAN"
az appservice plan create \
  --name "$APP_SERVICE_PLAN" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku B1 \
  --is-linux

# -------------------------------
# 🌐 Create Web App (Container-based)
# -------------------------------
echo "🌐 Creating Web App: $WEBAPP_NAME"
az webapp create \
  --resource-group "$RESOURCE_GROUP" \
  --plan "$APP_SERVICE_PLAN" \
  --name "$WEBAPP_NAME" \
  --deployment-container-image-name "$ACR_LOGIN_SERVER/shinyapp:latest"

# -------------------------------
# 🔐 Create Azure AD App Registration
# -------------------------------
echo "🔐 Creating Azure AD App Registration: $AAD_APP_NAME"
AAD_APP=$(az ad app create --display-name "$AAD_APP_NAME" --query "{appId:appId, id:objectId}" -o json)
AAD_APP_ID=$(echo $AAD_APP | jq -r '.appId')
AAD_APP_OBJECT_ID=$(echo $AAD_APP | jq -r '.id')
echo "✅ Azure AD App ID: $AAD_APP_ID"

# Create client secret
echo "🔑 Creating client secret..."
AAD_SECRET=$(az ad app credential reset \
  --id "$AAD_APP_ID" \
  --display-name "client-secret" \
  --query password -o tsv)
echo "✅ Secret created"

# -------------------------------
# 🔏 Create Key Vault
# -------------------------------
echo "🔏 Creating Key Vault: $KEYVAULT_NAME"
az keyvault create --name "$KEYVAULT_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION"

# -------------------------------
# 🔏 Grant Key Vault Access to Current Identity
# -------------------------------
KEYVAULT_ID=$(az keyvault show --name my-shiny-keyvault --query id -o tsv)
USER_ID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
  --assignee-object-id "$USER_ID" \
  --role "Key Vault Secrets Officer" \
  --scope "$KEYVAULT_ID"

# -------------------------------
# 🔏 Save Secret to Key Vault
# -------------------------------
echo "💾 Saving AAD Secret to Key Vault"
az keyvault secret set \
  --vault-name "$KEYVAULT_NAME" \
  --name "$SECRET_NAME" \
  --value "$AAD_SECRET"

# -------------------------------
# 👤 Enable Managed Identity for App Service
# -------------------------------
echo "👤 Enabling Managed Identity for App Service"
az webapp identity assign \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP"

IDENTITY_PRINCIPAL_ID=$(az webapp show \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query identity.principalId \
  -o tsv)
echo "✅ Identity Principal ID: $IDENTITY_PRINCIPAL_ID"

# -------------------------------
# 🔐 Grant Key Vault Access to Web App
# -------------------------------
echo "🔐 Granting Key Vault Access to Web App"
az role assignment create \
  --assignee "$IDENTITY_PRINCIPAL_ID" \
  --role "Key Vault Secrets User" \
  --scope "$KEYVAULT_ID"

# -------------------------------
# ✅ Final Output
# -------------------------------
echo ""
echo "✅ All resources have been configured!"
echo "🧾 Configuration details:"
echo "----------------------------------"
echo "App Service:     $WEBAPP_NAME"
echo "ACR:             $ACR_LOGIN_SERVER"
echo "Azure AD App ID: $AAD_APP_ID"
echo "Tenant ID:       $(az account show --query tenantId -o tsv)"
echo "Client Secret:   Saved in Key Vault ($KEYVAULT_NAME/$SECRET_NAME)"
echo "----------------------------------"

# -------------------------------
# 🌐 Output GitHub Actions and Configuration Credentials
# -------------------------------
echo ""
echo "🔑 Outputting GitHub Actions and Configuration Credentials:"
echo "----------------------------------"

# Output AZURE_CREDENTIALS
AZURE_CREDENTIALS=$(az ad sp create-for-rbac --name "$AAD_APP_NAME" --role contributor --scopes "/subscriptions/$(az account show --query id -o tsv)" --sdk-auth)
echo "AZURE_CREDENTIALS: $AZURE_CREDENTIALS"

# Output AAD Client ID and Tenant ID
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
echo "AAD_CLIENT_ID: $AAD_APP_ID"
echo "AZURE_TENANT_ID: $AZURE_TENANT_ID"

echo "----------------------------------"
echo "✅ All credentials have been output!"
