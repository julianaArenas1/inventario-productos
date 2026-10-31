# =====================================================================
# publicar.ps1 - Publicación de inventario-productos en Azure App Service
# Responsable: Camilo Ospina Hernández (Azure · Recursos y publicación)
# Fecha de publicación: 31/10/2026
#
# Este script no contiene credenciales. El inicio de sesión se hace de
# forma interactiva en el navegador con "az login".
#
# Requisitos:
#   - SDK de .NET (el proyecto apunta a net8.0)
#   - Azure CLI 2.x  (winget install -e --id Microsoft.AzureCLI)
#   - Ejecutar desde la raíz del repositorio (donde está CrudApp.csproj)
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File deploy\azure\publicar.ps1
# =====================================================================

# Detiene el script ante el primer error
$ErrorActionPreference = "Stop"

# --- Datos del despliegue (no son secretos) --------------------------
$Suscripcion   = "Azure for Students"                 # Suscripción del ITM
$GrupoRecursos = "rg-inventario-productos"            # Grupo de recursos
$AppService    = "inventario-productos-itm"           # Nombre del App Service
$Url           = "https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net"

# --- 1. Iniciar sesión y fijar la suscripción ------------------------
# Abre el navegador para autenticarse con la cuenta institucional
az login
# Fija la suscripción correcta. Sin este paso la CLI puede quedar apuntando
# a otra suscripción guardada y el despliegue falla con SubscriptionNotFound
az account set --subscription $Suscripcion

# --- 2. Compilar la versión publicable -------------------------------
# Compila en Release y deja los archivos listos en la carpeta publish
dotnet publish -c Release -o publish

# --- 3. Empaquetar ----------------------------------------------------
# Comprime el contenido de publish (no la carpeta) en app.zip
Compress-Archive -Path publish\* -DestinationPath app.zip -Force

# --- 4. Desplegar en App Service -------------------------------------
# Sube el zip con OneDeploy; Azure lo descomprime en el sitio y reinicia la app
az webapp deploy --resource-group $GrupoRecursos --name $AppService --src-path app.zip --type zip

# --- 5. Verificar -----------------------------------------------------
# La primera petición puede tardar 20-30 s porque el plan F1 suspende la app sin uso
Write-Host "Verificando $Url/health ..."
Invoke-RestMethod -Uri "$Url/health"
