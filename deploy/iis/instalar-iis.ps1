<#
  instalar-iis.ps1 - Practica 3 - IIS parte A - Los Indesplegables
  Deja un equipo con Windows 11 listo para alojar inventario-productos en IIS:
  habilita IIS, verifica .NET y el Hosting Bundle, crea el Application Pool,
  publica la aplicacion y da permisos a la carpeta.

  Uso (Windows PowerShell como ADMINISTRADOR, desde la raiz del repositorio):
    Set-ExecutionPolicy -Scope Process Bypass -Force
    .\deploy\iis\instalar-iis.ps1

  Se puede volver a ejecutar para republicar: detiene el App Pool, publica
  la nueva version y lo vuelve a iniciar.

  Nota: la app usa SQLite y crea app.db al iniciar, por eso el App Pool
  necesita permiso de MODIFICAR la carpeta (no solo lectura).
#>
param(
    [string]$Proyecto = "inventario-productos"
)

$ErrorActionPreference = "Stop"
$pool    = "$Proyecto-pool"
$destino = "C:\inetpub\$Proyecto"
# Busca el proyecto junto al script (deploy\iis) o, si no, en la carpeta actual
$repo = (Get-Location).Path
if (Test-Path (Join-Path $PSScriptRoot "..\..\CrudApp.csproj")) {
    $repo = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}
$csproj  = Join-Path $repo "CrudApp.csproj"

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { throw "Ejecuta Windows PowerShell como administrador." }
if (-not (Test-Path $csproj)) { throw "No se encontro $csproj. Ejecuta el script desde el repositorio clonado." }

function Actualizar-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Host "1/6 Habilitando IIS y sus herramientas de administracion..."
Enable-WindowsOptionalFeature -Online -All -NoRestart -FeatureName `
    IIS-WebServerRole, IIS-WebServer, IIS-ManagementConsole, IIS-ManagementScriptingTools | Out-Null

Write-Host "2/6 Verificando el SDK de .NET (8 o superior)..."
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue) -or -not (& dotnet --list-sdks)) {
    winget install --id Microsoft.DotNet.SDK.8 -e --accept-source-agreements --accept-package-agreements
    Actualizar-Path
}

Write-Host "3/6 Verificando el ASP.NET Core Hosting Bundle..."
$modulo = Join-Path $env:ProgramFiles "IIS\Asp.Net Core Module\V2\aspnetcorev2.dll"
if (-not (Test-Path $modulo)) {
    # Si winget falla, descargarlo de https://dotnet.microsoft.com/download/dotnet/8.0
    # (ASP.NET Core Runtime -> Windows -> Hosting Bundle) e instalarlo a mano.
    winget install --id Microsoft.DotNet.HostingBundle.8 -e --accept-source-agreements --accept-package-agreements
    iisreset | Out-Null
}

Write-Host "4/6 Creando el Application Pool $pool (Sin codigo administrado, Integrada)..."
Import-Module WebAdministration
if (-not (Test-Path "IIS:\AppPools\$pool")) {
    New-WebAppPool -Name $pool | Out-Null
}
Set-ItemProperty "IIS:\AppPools\$pool" -Name managedRuntimeVersion -Value ""
Set-ItemProperty "IIS:\AppPools\$pool" -Name managedPipelineMode -Value "Integrated"
if ((Get-WebAppPoolState -Name $pool).Value -eq "Started") {
    Stop-WebAppPool -Name $pool          # evita archivos bloqueados al publicar
    Start-Sleep -Seconds 2
}

Write-Host "5/6 Publicando la aplicacion en $destino..."
Actualizar-Path
dotnet publish $csproj -c Release -o $destino
if ($LASTEXITCODE -ne 0) { throw "dotnet publish fallo." }

Write-Host "6/6 Dando permiso de modificar al App Pool (SQLite crea app.db)..."
icacls $destino /grant "IIS AppPool\${pool}:(OI)(CI)M" | Out-Null
Start-WebAppPool -Name $pool

Write-Host ""
Write-Host "Listo. Para crear el sitio en IIS (parte B):"
Write-Host "  Ruta fisica: $destino"
Write-Host "  App Pool:    $pool"
Write-Host "  Puerto:      uno libre (revisar con: netstat -ano | findstr :8080)"
