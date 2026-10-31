<#
  crear-sitio-iis.ps1 - Practica 3 - IIS parte B - Los Indesplegables
  Crea el sitio de IIS para inventario-productos sobre el Application Pool de
  la parte A, lo deja escuchando en un puerto propio (8080) y verifica que la
  pagina inicial y /health respondan.

  Requisitos (los deja listos instalar-iis.ps1):
    - IIS y el ASP.NET Core Hosting Bundle instalados
    - Application Pool  <proyecto>-pool  creado
    - Aplicacion publicada en  C:\inetpub\<proyecto>

  Uso (Windows PowerShell como ADMINISTRADOR):
    Set-ExecutionPolicy -Scope Process Bypass -Force
    .\deploy\iis\crear-sitio-iis.ps1              # puerto 8080
    .\deploy\iis\crear-sitio-iis.ps1 -Puerto 8085 # si el 8080 esta ocupado

  Se puede volver a ejecutar: si el sitio ya existe no lo duplica, solo lo
  inicia y repite la verificacion.
#>
param(
    [string]$Proyecto = "inventario-productos",
    [int]$Puerto = 8080
)

$ErrorActionPreference = "Stop"
$pool = "$Proyecto-pool"
$ruta = "C:\inetpub\$Proyecto"

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { throw "Ejecuta Windows PowerShell como administrador." }

Import-Module WebAdministration

Write-Host "1/5 Comprobando lo que dejo la parte A..."
if (-not (Test-Path "IIS:\AppPools\$pool")) {
    throw "No existe el Application Pool $pool. Ejecuta primero instalar-iis.ps1."
}
if (-not (Test-Path (Join-Path $ruta "web.config"))) {
    throw "No hay una aplicacion publicada en $ruta (falta web.config). Ejecuta primero instalar-iis.ps1."
}

Write-Host "2/5 Comprobando que el puerto $Puerto este libre..."
$existe = Test-Path "IIS:\Sites\$Proyecto"
$ocupado = Get-NetTCPConnection -LocalPort $Puerto -State Listen -ErrorAction SilentlyContinue
if ($ocupado -and -not $existe) {
    $pid_ = ($ocupado | Select-Object -First 1).OwningProcess
    throw "El puerto $Puerto esta ocupado (PID $pid_). Usa otro: .\deploy\iis\crear-sitio-iis.ps1 -Puerto 8085"
}

Write-Host "3/5 Creando el sitio $Proyecto (pool $pool, ruta $ruta, http *:$Puerto)..."
if (-not $existe) {
    New-Website -Name $Proyecto -ApplicationPool $pool -PhysicalPath $ruta `
        -IPAddress "*" -Port $Puerto -HostHeader "" | Out-Null
} else {
    Write-Host "    El sitio ya existe, no se vuelve a crear."
}

Write-Host "4/5 Punto de entrada (etiqueta aspNetCore de web.config):"
Select-String -Path (Join-Path $ruta "web.config") -Pattern "<aspNetCore" |
    ForEach-Object { Write-Host "    $($_.Line.Trim())" }

Write-Host "5/5 Iniciando el sitio y verificando..."
if ((Get-WebAppPoolState -Name $pool).Value -ne "Started") { Start-WebAppPool -Name $pool }
if ((Get-WebsiteState -Name $Proyecto).Value -ne "Started") { Start-Website -Name $Proyecto }

foreach ($url in "http://localhost:$Puerto/", "http://localhost:$Puerto/health") {
    try {
        # el primer arranque de la app (migracion de SQLite) puede tardar unos segundos
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 60
        Write-Host "    $url -> $($r.StatusCode)"
        if ($url -like "*/health") { Write-Host "    $($r.Content)" }
    } catch {
        $codigo = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { "sin respuesta" }
        Write-Host "    $url -> ERROR ($codigo). Revisa la tabla de solucion de problemas del README."
    }
}

Write-Host ""
Write-Host "Listo. Abre http://localhost:$Puerto y http://localhost:$Puerto/health"
