using Microsoft.EntityFrameworkCore;
using CrudApp.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(
        builder.Configuration.GetConnectionString("DefaultConnection")
    )
);

var app = builder.Build();

// Crea o actualiza automáticamente la base de datos al iniciar la aplicación
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    db.Database.Migrate();
}

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();

// Permite servir wwwroot/index.html al entrar a "/"
app.UseDefaultFiles();
app.UseStaticFiles();

app.UseRouting();

// Endpoint para verificar el estado y el entorno del despliegue
app.MapGet("/health", (IConfiguration config, IWebHostEnvironment env) =>
    Results.Ok(new
    {
        status = "OK",
        environment = env.EnvironmentName,
        deployTarget = config["DeployTarget"] ?? "sin configurar"
    })
);

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Products}/{action=Index}/{id?}");

app.Run();
