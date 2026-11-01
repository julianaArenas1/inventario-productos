# Inventario de Productos

Aplicación web para la gestión de productos mediante operaciones CRUD (crear, consultar, editar y eliminar), desarrollada con **ASP.NET Core MVC sobre .NET 8**, **Entity Framework Core** y **SQLite**.

Este proyecto fue utilizado por el equipo **Los Indesplegables** para realizar la publicación y verificación de la aplicación en **IIS (on-premises)** y **Azure App Service**, como parte de la Práctica 3 de Despliegue de Software.

---

## Equipo

**Los Indesplegables**

| Integrante | Responsabilidad principal | Contribución verificable |
| --- | --- | --- |
| **Juliana Arenas Arias** | Preparación de la aplicación, endpoint `/health`, configuración por entorno e integración continua | Rama `juliana/preparacion-app` · PR #1 fusionado por Camilo · preparación de la aplicación y pipeline CI |
| **Oscar Alexis Pineda Henao** | IIS: instalación, Hosting Bundle, publicación y Application Pool | Rama `alexis/iis-instalacion` · PR #2 fusionado por Heyner · `deploy/iis/instalar-iis.ps1` y evidencias IIS 01–04 |
| **Heyner Mena Campaña** | IIS: sitio, puerto, `web.config`, verificación y solución de problemas | Rama `heyner/iis-sitio` · `deploy/iis/crear-sitio-iis.ps1`, evidencias IIS 05–11 y documentación |
| **Camilo Ospina Hernández** | Azure: grupo de recursos, App Service y publicación | Rama `camilo/azure-publicacion` · PR #3 fusionado por Juan · `deploy/azure/publicar.ps1` y evidencias Azure 01–04b |
| **Juan Andrés Ramírez Castañeda** | Azure: Application Settings, HTTPS Only y verificación pública | Rama `juan/azure-configuracion` · evidencias Azure 05–09 y documentación de verificación |

---

## Tecnología utilizada

| Componente | Tecnología |
| --- | --- |
| Backend | ASP.NET Core MVC |
| Runtime | .NET 8 |
| Lenguaje | C# |
| ORM | Entity Framework Core |
| Base de datos | SQLite |
| Frontend | Razor Views, HTML y Bootstrap |
| Servidor local | IIS |
| Nube | Azure App Service |
| Integración continua | GitHub Actions |
| Control de versiones | Git y GitHub |

---

## Funcionalidad

La aplicación permite:

- Consultar productos.
- Crear nuevos productos.
- Editar productos existentes.
- Consultar el detalle de un producto.
- Eliminar productos.
- Verificar el estado y entorno del despliegue mediante `/health`.

---

## Estructura del repositorio

```text
inventario-productos/
├── .github/
│   └── workflows/
│       └── ci.yml
├── Controllers/
├── Data/
├── Migrations/
├── Models/
├── Views/
├── wwwroot/
│   └── index.html
├── deploy/
│   ├── iis/
│   │   ├── instalar-iis.ps1
│   │   └── crear-sitio-iis.ps1
│   └── azure/
│       └── publicar.ps1
├── evidencias/
│   ├── iis/
│   └── azure/
├── Program.cs
├── CrudApp.csproj
├── appsettings.json
└── README.md
```

---

## Ejecución local

Restaurar las dependencias:

```bash
dotnet restore
```

Aplicar las migraciones manualmente, si es necesario:

```bash
dotnet ef database update
```

Ejecutar la aplicación:

```bash
dotnet run
```

La aplicación queda disponible en:

```text
http://localhost:5000
```

El endpoint de verificación es:

```text
http://localhost:5000/health
```

La aplicación también ejecuta automáticamente las migraciones de Entity Framework mediante `Database.Migrate()` al iniciar, permitiendo crear la base SQLite si todavía no existe.

---

## Preparación de la aplicación e integración continua

**Responsable:** Juliana Arenas Arias

Antes de realizar los despliegues se preparó la aplicación para funcionar en ambos ambientes.

Se realizaron los siguientes cambios:

- Se agregó el endpoint `/health`.
- Se agregó la configuración `DeployTarget`.
- Se agregó `wwwroot/index.html` como página inicial.
- Se habilitaron `UseDefaultFiles()` y `UseStaticFiles()`.
- Se configuró la aplicación automática de migraciones de SQLite.
- Se creó un pipeline de integración continua con GitHub Actions.

La configuración local contiene:

```json
"DeployTarget": "IIS (local)"
```

El endpoint `/health` devuelve:

```json
{
  "status": "OK",
  "environment": "Production",
  "deployTarget": "IIS (local)"
}
```

---

## Integración continua

El workflow se encuentra en:

```text
.github/workflows/ci.yml
```

El pipeline se ejecuta en cada Pull Request y en cada push hacia `main`.

El proceso realiza:

1. Descarga del repositorio.
2. Configuración de .NET 8.
3. Restauración de dependencias.
4. Compilación en modo Release.
5. Publicación de la aplicación.
6. Almacenamiento del resultado como artefacto.

El pipeline fue ejecutado correctamente antes de integrar los cambios a `main`.

---

## Publicación en IIS

**Fecha de publicación:** 31 de octubre de 2026

### Instalación, publicación y Application Pool

**Responsable:** Oscar Alexis Pineda Henao

La aplicación fue publicada en Windows 11 utilizando IIS.

Se habilitó IIS y se instaló el **ASP.NET Core Hosting Bundle para .NET 8**.

Se verificó la disponibilidad del módulo:

```text
AspNetCoreModuleV2
```

Posteriormente se publicó la aplicación en:

```text
C:\inetpub\inventario-productos
```

Se creó el Application Pool:

```text
inventario-productos-pool
```

| Propiedad | Valor |
| --- | --- |
| .NET CLR | Sin código administrado |
| Canalización | Integrada |
| Estado | Iniciado |

El Application Pool cuenta con permiso de **Modificar** sobre la carpeta publicada, necesario porque la aplicación crea y modifica el archivo SQLite `app.db`.

Los comandos utilizados se encuentran documentados en:

```text
deploy/iis/instalar-iis.ps1
```

---

### Sitio, puerto y verificación

**Responsable:** Heyner Mena Campaña

Se creó el sitio:

```text
inventario-productos
```

con la siguiente configuración:

| Propiedad | Valor |
| --- | --- |
| Application Pool | `inventario-productos-pool` |
| Ruta física | `C:\inetpub\inventario-productos` |
| Protocolo | HTTP |
| Puerto | `8080` |
| IP | Todas las no asignadas |

La aplicación se encuentra disponible en:

```text
http://localhost:8080
```

El estado puede verificarse mediante:

```text
http://localhost:8080/health
```

Respuesta esperada:

```json
{
  "status": "OK",
  "environment": "Production",
  "deployTarget": "IIS (local)"
}
```

Los comandos relacionados con la creación del sitio se encuentran en:

```text
deploy/iis/crear-sitio-iis.ps1
```

---

## Problema verificado en IIS

Durante las pruebas se reprodujo:

```text
HTTP Error 403.14 Forbidden
```

La ruta física del sitio fue modificada temporalmente para apuntar a una carpeta vacía.

IIS no encontró un documento predeterminado ni el archivo `web.config`, por lo que respondió con el error 403.14.

La solución consistió en restaurar la ruta correcta:

```text
C:\inetpub\inventario-productos
```

Después de corregirla, la aplicación volvió a responder correctamente.

---

## Publicación en Azure App Service

**Fecha de publicación:** 31 de octubre de 2026

### Recursos y publicación

**Responsable:** Camilo Ospina Hernández

Se creó la infraestructura necesaria utilizando una suscripción **Azure for Students**.

| Elemento | Valor |
| --- | --- |
| Suscripción | Azure for Students |
| Grupo de recursos | `rg-inventario-productos` |
| App Service | `inventario-productos-itm` |
| App Service Plan | `plan-inventario` |
| Plan | Free F1 |
| Sistema operativo | Windows |
| Región | Brazil South |
| Runtime | .NET 8 |

URL pública:

https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net

La aplicación fue publicada mediante Azure CLI utilizando despliegue ZIP.

Los comandos utilizados se encuentran en:

```text
deploy/azure/publicar.ps1
```

Flujo utilizado:

```powershell
az login
az account set --subscription "Azure for Students"
dotnet publish -c Release -o publish
Compress-Archive -Path publish\* -DestinationPath app.zip -Force
az webapp deploy --resource-group rg-inventario-productos --name inventario-productos-itm --src-path app.zip --type zip
```

El despliegue finalizó con:

```text
provisioningState: Succeeded
```

También se verificó el funcionamiento completo del CRUD en Azure, incluida la creación y consulta de productos mediante SQLite.

---

## Problemas encontrados en Azure

### Restricción de regiones

Los primeros intentos en **East US** y **South Central US** fueron rechazados por la política:

```text
sys.regionrestriction
```

Se seleccionó finalmente:

```text
Brazil South
```

### Cuota del plan F1

En algunas regiones la cuota disponible para el plan Free F1 era cero.

En Brazil South sí existía disponibilidad para crear el App Service Plan.

### SubscriptionNotFound

Azure CLI tenía seleccionada una suscripción diferente.

Se solucionó ejecutando nuevamente:

```powershell
az login
```

y seleccionando la suscripción:

```text
Azure for Students
```

---

## Configuración y verificación en Azure

**Responsable:** Juan Andrés Ramírez Castañeda

Se configuraron las siguientes variables de entorno:

| Variable | Valor |
| --- | --- |
| `ASPNETCORE_ENVIRONMENT` | `Production` |
| `DeployTarget` | `Azure App Service` |

El valor `DeployTarget` configurado en Azure sobrescribe el valor `IIS (local)` definido en `appsettings.json`.

---

## HTTPS

Se habilitó:

```text
HTTPS Only
```

También se verificó una versión mínima TLS 1.2.

Al realizar una solicitud mediante HTTP:

```powershell
curl.exe -I http://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net/
```

Azure responde:

```text
HTTP/1.1 301 Moved Permanently
Location: https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net/
```

Esto confirma que el tráfico HTTP es redirigido automáticamente a HTTPS.

---

## Cómo verificar el despliegue

### IIS

Aplicación:

```text
http://localhost:8080
```

Estado:

```text
http://localhost:8080/health
```

Respuesta:

```json
{
  "status": "OK",
  "environment": "Production",
  "deployTarget": "IIS (local)"
}
```

### Azure App Service

Aplicación:

https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net/

Estado:

https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net/health

Respuesta:

```json
{
  "status": "OK",
  "environment": "Production",
  "deployTarget": "Azure App Service"
}
```

La diferencia entre `IIS (local)` y `Azure App Service` permite verificar que la misma aplicación fue publicada correctamente en dos entornos diferentes.

---

## Evidencias

Las evidencias se encuentran organizadas en:

```text
evidencias/
├── iis/
└── azure/
```

### Evidencias de IIS

Incluyen:

- IIS habilitado.
- Hosting Bundle.
- `AspNetCoreModuleV2`.
- Carpeta publicada.
- Scripts utilizados.
- Permisos de la carpeta.
- Application Pool.
- Sitio.
- Binding y puerto.
- `web.config`.
- Aplicación funcionando.
- `/health`.
- Error 403.14 y solución.

### Evidencias de Azure

Incluyen:

- Grupo de recursos.
- App Service Plan.
- Restricción de región encontrada.
- App Service.
- Publicación exitosa.
- CRUD funcionando.
- Application Settings.
- HTTPS Only.
- URL pública.
- `/health`.
- Redirección HTTP hacia HTTPS.

---

## Repositorio

https://github.com/julianaArenas1/inventario-productos

El repositorio fue compartido con el usuario de GitHub del docente:

```text
oalarconpe
```

---

## Video de evidencia

**Pendiente de agregar el enlace final del video.**

---

## Origen del proyecto base

Este proyecto parte de la aplicación pública **C# CRUD Web Application**:

https://github.com/peak-flow/csharp

El proyecto original se distribuye bajo licencia MIT.

A partir de esta base, el equipo realizó las adaptaciones, configuraciones, scripts, documentación y actividades de despliegue necesarias para publicar la aplicación en IIS y Azure App Service.
