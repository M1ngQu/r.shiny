#!/bin/bash

# -------------------------------
# ⚙️ 参数配置（可自定义）
# -------------------------------
RESOURCE_GROUP="r-shiny-rg"
LOCATION="australiasoutheast"

ACR_NAME="rshinycr" # 会拼接 .azurecr.io
APP_SERVICE_PLAN="shiny-plan"
WEBAPP_NAME="shiny-web-app"

KEYVAULT_NAME="my-shiny-keyvault"
SECRET_NAME="aad-client-secret"

AAD_APP_NAME="shiny-ad-app"

# -------------------------------
# 🛠 创建资源组
# -------------------------------
echo "📁 创建资源组: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# -------------------------------
# 🐳 创建 ACR
# -------------------------------
echo "🐳 创建 ACR: $ACR_NAME"
az acr create --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_NAME" \
  --sku Basic \
  --admin-enabled true

ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
echo "✅ ACR 登录地址: $ACR_LOGIN_SERVER"

# -------------------------------
# 🧱 创建 App Service Plan（Linux）
# -------------------------------
echo "🧱 创建 App Service Plan: $APP_SERVICE_PLAN"
az appservice plan create \
  --name "$APP_SERVICE_PLAN" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku B1 \
  --is-linux

# -------------------------------
# 🌐 创建 Web App（使用容器）
# -------------------------------
echo "🌐 创建 Web App: $WEBAPP_NAME"
az webapp create \
  --resource-group "$RESOURCE_GROUP" \
  --plan "$APP_SERVICE_PLAN" \
  --name "$WEBAPP_NAME" \
  --deployment-container-image-name "$ACR_LOGIN_SERVER/shinyapp:latest"

# -------------------------------
# 🔐 创建 Azure AD 应用注册
# -------------------------------
echo "🔐 创建 Azure AD 应用注册: $AAD_APP_NAME"
AAD_APP=$(az ad app create --display-name "$AAD_APP_NAME" --query "{appId:appId, id:objectId}" -o json)
AAD_APP_ID=$(echo $AAD_APP | jq -r '.appId')
AAD_APP_OBJECT_ID=$(echo $AAD_APP | jq -r '.id')
echo "✅ Azure AD App ID: $AAD_APP_ID"

# 创建 client secret
echo "🔑 创建 client secret..."
AAD_SECRET=$(az ad app credential reset \
  --id "$AAD_APP_ID" \
  --display-name "client-secret" \
  --query password -o tsv)
echo "✅ Secret 已创建"


# -------------------------------
# 🔏 创建 Key Vault
# -------------------------------

echo "🔏 创建 Key Vault: $KEYVAULT_NAME"
az keyvault create --name "$KEYVAULT_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION"

# -------------------------------
# 🔏 为当前身份授予 Key Vault 权限
# -------------------------------
KEYVAULT_ID=$(az keyvault show --name my-shiny-keyvault --query id -o tsv)
USER_ID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
  --assignee-object-id "$USER_ID" \
  --role "Key Vault Secrets Officer" \
  --scope "$KEYVAULT_ID"
  

# -------------------------------
# 🔏 保存 secret
# -------------------------------

echo "💾 保存 AAD Secret 到 Key Vault"
az keyvault secret set \
  --vault-name "$KEYVAULT_NAME" \
  --name "$SECRET_NAME" \
  --value "$AAD_SECRET"

# -------------------------------
# 👤 启用 App Service 托管身份
# -------------------------------
echo "👤 启用 App Service 托管身份"
az webapp identity assign \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP"

IDENTITY_PRINCIPAL_ID=$(az webapp show \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query identity.principalId \
  -o tsv)
echo "✅ 身份 ID: $IDENTITY_PRINCIPAL_ID"

# -------------------------------
# 🔐 授予 Key Vault 权限给 Web App
# -------------------------------
echo "🔐 授予 Key Vault 权限"
az role assignment create \
  --assignee "$IDENTITY_PRINCIPAL_ID" \
  --role "Key Vault Secrets User" \
  --scope "$KEYVAULT_ID"

# -------------------------------
# ✅ 最终输出
# -------------------------------
echo ""
echo "✅ 所有资源配置完成！"
echo "🧾 配置信息如下："
echo "----------------------------------"
echo "App Service:     $WEBAPP_NAME"
echo "ACR:             $ACR_LOGIN_SERVER"
echo "Azure AD App ID: $AAD_APP_ID"
echo "Tenant ID:       $(az account show --query tenantId -o tsv)"
echo "Client Secret:   已保存于 Key Vault ($KEYVAULT_NAME/$SECRET_NAME)"
echo "----------------------------------"

# -------------------------------
# 🌐 输出 GitHub Actions 和配置所需的凭据
# -------------------------------
echo ""
echo "🔑 输出 GitHub Actions 和配置所需的凭据："
echo "----------------------------------"

# 输出 AZURE_CREDENTIALS
AZURE_CREDENTIALS=$(az ad sp create-for-rbac --name "$AAD_APP_NAME" --role contributor --scopes "/subscriptions/$(az account show --query id -o tsv)" --sdk-auth)
echo "AZURE_CREDENTIALS: $AZURE_CREDENTIALS"

# 输出 AAD 客户端 ID 和租户 ID
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
echo "AAD_CLIENT_ID: $AAD_APP_ID"
echo "AZURE_TENANT_ID: $AZURE_TENANT_ID"

echo "----------------------------------"
echo "✅ 所有凭据已输出！"
