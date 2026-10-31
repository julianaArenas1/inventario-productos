# Inventario de Productos

Aplicación web para la gestión de productos mediante operaciones CRUD (crear, consultar, editar y eliminar), desarrollada con ASP.NET Core MVC sobre .NET 8.

Este proyecto será utilizado por el equipo Los Indesplegables para realizar la publicación y verificación de la aplicación en IIS y Azure App Service.

## Equipo

**Los Indesplegables**

| Integrante | Responsabilidad principal |
| --- | --- |
| Juliana Arenas Arias | Preparación de la aplicación, endpoint /health, configuración por entorno e integración continua |
| Oscar Alexis Pineda Henao | IIS: instalación, Hosting Bundle, publicación y Application Pool |
| Heyner Mena Campaña | IIS: sitio, puerto, punto de entrada, verificación y solución de problemas |
| Camilo Ospina Hernández | Azure: creación de recursos y publicación en App Service |
| Juan Andres Ramirez Castañeda | Azure: Application Settings, HTTPS Only y verificación pública |

## Tecnología utilizada

- ASP.NET Core MVC
- .NET 8
- C#
- Entity Framework Core
- SQLite
- Bootstrap
- IIS
- Azure App Service
- GitHub Actions

## Funcionalidad

La aplicación permite:

- Consultar productos.
- Crear nuevos productos.
- Editar productos existentes.
- Consultar el detalle de un producto.
- Eliminar productos.
- Validar la disponibilidad de la aplicación mediante `/health`.

## Estructura del repositorio

```text
inventario-productos/
├── Controllers/
├── Data/
├── Migrations/
├── Models/
├── Views/
├── deploy/
│   ├── iis/
│   └── azure/
├── evidencias/
│   ├── iis/
│   └── azure/
├── Program.cs
├── CrudApp.csproj
├── appsettings.json
└── README.md
cat > README.md <<'EOF'
# Inventario de Productos

Aplicación web para la gestión de productos mediante operaciones CRUD (crear, consultar, editar y eliminar), desarrollada con ASP.NET Core MVC sobre .NET 8.

Este proyecto será utilizado por el equipo Los Indesplegables para realizar la publicación y verificación de la aplicación en IIS y Azure App Service.

## Equipo

**Los Indesplegables**

| Integrante | Responsabilidad principal |
| --- | --- |
| Juliana Arenas Arias | Preparación de la aplicación, endpoint /health, configuración por entorno e integración continua |
| Oscar Alexis Pineda Henao | IIS: instalación, Hosting Bundle, publicación y Application Pool |
| Heyner Mena Campaña | IIS: sitio, puerto, punto de entrada, verificación y solución de problemas |
| Camilo Ospina Hernández | Azure: creación de recursos y publicación en App Service |
| Juan Andres Ramirez Castañeda | Azure: Application Settings, HTTPS Only y verificación pública |

## Tecnología utilizada

- ASP.NET Core MVC
- .NET 8
- C#
- Entity Framework Core
- SQLite
- Bootstrap
- IIS
- Azure App Service
- GitHub Actions

## Funcionalidad

La aplicación permite:

- Consultar productos.
- Crear nuevos productos.
- Editar productos existentes.
- Consultar el detalle de un producto.
- Eliminar productos.
- Validar la disponibilidad de la aplicación mediante `/health`.

## Estructura del repositorio

```text
inventario-productos/
├── Controllers/
├── Data/
├── Migrations/
├── Models/
├── Views/
├── deploy/
│   ├── iis/
│   └── azure/
├── evidencias/
│   ├── iis/
│   └── azure/
├── Program.cs
├── CrudApp.csproj
├── appsettings.json
└── README.md


## Publicación en Azure · Recursos y publicación

**Responsable:** Camilo Ospina Hernández · **Fecha de publicación:** 31/10/2026

### Recursos creados

| Elemento | Valor |
| --- | --- |
| Suscripción | Azure for Students |
| Grupo de recursos | `rg-inventario-productos` |
| App Service | `inventario-productos-itm` |
| Plan de App Service | `plan-inventario` · Free F1 · Windows |
| Región | Brazil South |
| Pila | .NET 8 (LTS) |
| URL pública | https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net |

El acceso de Juan Andrés Ramírez se dio con el rol **Colaborador** en el grupo de recursos (Control de acceso IAM), sin compartir contraseñas.

### Publicación

Se publicó con Azure CLI y despliegue zip (OneDeploy). Los comandos están en [`deploy/azure/publicar.ps1`](deploy/azure/publicar.ps1):

```powershell
az login
az account set --subscription "Azure for Students"
dotnet publish -c Release -o publish
Compress-Archive -Path publish\* -DestinationPath app.zip -Force
az webapp deploy --resource-group rg-inventario-productos --name inventario-productos-itm --src-path app.zip --type zip
```

Resultado: `provisioningState: Succeeded`. La verificación inmediata de `/health` respondió `{"status":"OK","environment":"Production","deployTarget":"IIS (local)"}`; el valor `IIS (local)` viene de `appsettings.json` y se reemplaza en Azure con el Application Setting que configura Juan.

App Service en Windows también corre sobre IIS, administrado por Azure: la respuesta HTTP incluye `Server: Microsoft-IIS/10.0`.

### Problemas encontrados y solución

| Problema | Causa | Solución |
| --- | --- | --- |
| `Resource was disallowed by Azure` al crear en South Central US y East US | La suscripción Azure for Students tiene la política `sys.regionrestriction`, que solo permite westus2, brazilsouth, spaincentral, northcentralus y francecentral | Consultar la política con `az policy assignment show --name sys.regionrestriction --query parameters` y elegir una región permitida |
| `Operation cannot be completed without additional quota (F1 VMs): 0` | La cuota del plan gratuito F1 es 0 en algunas regiones permitidas | Probar otra región permitida; en **Brazil South** sí había cuota F1 |
| `SubscriptionNotFound` al desplegar | La CLI tenía guardada una suscripción distinta | `az login` y seleccionar *Azure for Students* (`az account set`) |

### Evidencias (`evidencias/azure/`)

| Archivo | Qué muestra |
| --- | --- |
| `01-grupo-recursos.png` | Grupo de recursos `rg-inventario-productos` creado en Azure for Students |
| `02-plan-app-service.png` | Plan `plan-inventario`: Brazil South, Windows, Free F1 |
| `02a-intento-east-us.png` | Primer intento de creación en East US, bloqueado por la política de regiones |
| `03-app-service-overview.png` | App Service en ejecución: grupo, región, plan F1, .NET 8 y URL |
| `04-publicacion-exitosa.png` | Página inicial cargando en la URL pública de Azure |
| `04a-crud-listado-azure.png` | Listado de productos funcionando en Azure (escritura en SQLite) |
| `04b-crud-crear-producto-azure.png` | Formulario de creación de producto en Azure |
