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
```


## Publicación en Azure – Configuración y verificación

**Responsable:** Juan Andrés Ramírez Castañeda  
**Fecha:** 31 de octubre de 2026  
**Grupo de recursos:** `rg-inventario-productos`  
**App Service:** `inventario-productos-itm`  
**Sistema operativo:** Windows  
**Tecnología:** ASP.NET Core MVC – .NET 8  
**Región:** Brazil South

### Configuración de variables de entorno

Se configuraron dos variables en Azure App Service mediante la sección **Configuración → Variables de entorno**.

| Variable | Valor |
|---|---|
| `ASPNETCORE_ENVIRONMENT` | `Production` |
| `DeployTarget` | `Azure App Service` |

Estas variables permiten establecer el entorno de producción e identificar el servicio donde se encuentra publicada la aplicación.

### Configuración de HTTPS

Se verificó que la opción **HTTPS Only** estuviera habilitada en la configuración general del App Service.

También se comprobó que la versión mínima de TLS entrante estuviera configurada en 1.2.

Para verificar la redirección HTTP a HTTPS se utilizó PowerShell con el siguiente comando:

```powershell
curl.exe -I http://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net/
```

La respuesta obtenida fue:

```text
HTTP/1.1 301 Moved Permanently
Location: https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net/
```

Esto confirma que las solicitudes HTTP son redirigidas a HTTPS.

### Cómo verificar el despliegue

La aplicación se encuentra disponible públicamente en:

https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net/

Para comprobar su estado se puede acceder al endpoint:

https://inventario-productos-itm-gnf0fresfydyhrgg.brazilsouth-01.azurewebsites.net/health

La respuesta obtenida fue:

```json
{
  "status": "OK",
  "environment": "Production",
  "deployTarget": "Azure App Service"
}
```

Estos resultados confirman que la aplicación responde correctamente en Azure y reconoce las variables de entorno configuradas.

### Evidencias de la configuración

Las evidencias se encuentran almacenadas en `evidencias/azure/`:

| Archivo | Descripción |
|---|---|
| `05-application-settings.png` | Variables de entorno configuradas en Azure App Service. |
| `06-https-only.png` | Configuración HTTPS Only habilitada. |
| `07-app-url-publica.png` | Aplicación funcionando mediante la URL pública de Azure. |
| `08-health-azure.png` | Respuesta del endpoint `/health` con los valores esperados. |
| `09-redireccion-https.png` | Comprobación de redirección HTTP 301 hacia HTTPS mediante PowerShell. |

**Resultado final:** Se verificó correctamente la configuración de producción, la disponibilidad pública de la aplicación, el funcionamiento de `/health` y la redirección segura hacia HTTPS.