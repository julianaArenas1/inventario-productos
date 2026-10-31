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


## Publicación en IIS · Sitio y verificación

**Responsable:** Heyner Mena Campaña · **Fecha:** COMPLETAR_FECHA

Esta parte toma la aplicación publicada y el Application Pool que dejó listos Alexis (carpeta `C:\inetpub\inventario-productos` y grupo `inventario-productos-pool`), crea el sitio en IIS, lo deja respondiendo en un puerto propio y verifica la aplicación en local. Los pasos están en [`deploy/iis/crear-sitio-iis.ps1`](deploy/iis/crear-sitio-iis.ps1).

### Sitio y enlace

| Elemento | Valor |
| --- | --- |
| Nombre del sitio | `inventario-productos` |
| Grupo de aplicaciones | `inventario-productos-pool` |
| Ruta física | `C:\inetpub\inventario-productos` |
| Enlace | `http`, IP «Todas las no asignadas», puerto **8080**, nombre de host vacío |
| URL de la aplicación | http://localhost:8080 |
| URL de verificación | http://localhost:8080/health |

Antes de crear el sitio se comprobó con `netstat -ano | findstr :8080` que el puerto estuviera libre (sin resultados).

![Configuración del sitio](evidencias/iis/05-sitio-configuracion.png)

![Enlace y puerto](evidencias/iis/06-binding-puerto.png)

### Punto de entrada (`web.config`)

`dotnet publish` genera un `web.config` en la carpeta publicada. Su etiqueta `aspNetCore` es el punto de entrada: le dice a IIS cómo arrancar la aplicación y le entrega todas las peticiones.

```xml
<aspNetCore processPath="dotnet" arguments=".\CrudApp.dll" stdoutLogEnabled="false" stdoutLogFile=".\logs\stdout" hostingModel="inprocess" />
```

| Atributo | Valor | Qué significa |
| --- | --- | --- |
| `processPath` | `dotnet` | Programa que ejecuta la aplicación (el runtime de .NET) |
| `arguments` | `.\CrudApp.dll` | Ensamblado de la aplicación que arranca |
| `hostingModel` | `inprocess` | La app corre dentro del proceso de IIS (`w3wp.exe`), sin servidor Kestrel aparte |

IIS no sirve las páginas por sí mismo: el módulo ASP.NET Core (`AspNetCoreModuleV2`) recibe cada petición y la pasa a la aplicación, que sirve `wwwroot/index.html` en «/» gracias a `UseDefaultFiles()` y `UseStaticFiles()`.

![web.config](evidencias/iis/07-punto-entrada-webconfig.png)

### Verificación

| URL | Respuesta esperada |
| --- | --- |
| http://localhost:8080 | Página inicial de Inventario de Productos |
| http://localhost:8080/health | `{"status":"OK","environment":"Production","deployTarget":"IIS (local)"}` |

`environment` es `Production` porque IIS no define `ASPNETCORE_ENVIRONMENT`, y `deployTarget` viene de `appsettings.json`; en Azure ese valor se sobrescribe con un Application Setting.

![Aplicación en localhost](evidencias/iis/08-app-localhost.png)

![/health en localhost](evidencias/iis/09-health-localhost.png)

### Solución de problemas

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| Error 500.19 | Falta el Hosting Bundle o el `web.config` es inválido | Instalar el Hosting Bundle y reiniciar IIS (`net stop was /y` y `net start w3svc`) |
| Error 500.30 / 500.31 | La app no arranca o falta el runtime de .NET | Activar `stdoutLogEnabled="true"` en `web.config`, crear la carpeta `logs` y leer el log; desactivarlo al terminar |
| Error 403.14 | La ruta física no apunta a la carpeta publicada | Corregir la ruta del sitio |
| 404 en «/» | La app no tiene página inicial | Revisar `wwwroot/index.html` y `UseDefaultFiles()` |
| El sitio no inicia | Puerto ocupado | Cambiar el enlace a otro puerto |
| Acceso denegado | Permisos de la carpeta | Agregar `IIS AppPool\inventario-productos-pool` a la carpeta |
| 500.30 con SQLite (propio de esta app) | La app crea `app.db` al iniciar y el Application Pool no puede escribir en la carpeta | Dar al Application Pool permiso de **Modificar**, no solo lectura |

Para republicar, detener primero el Application Pool (evita archivos bloqueados) y volver a iniciarlo al terminar.

### Problema encontrado en nuestro despliegue

COMPLETAR_PROBLEMA: describir el error real que apareció (código y mensaje), su causa y cómo se resolvió.
