using System.Text;
using IzmirimCard.Api.Data;
using IzmirimCard.Api.Hubs;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// 1. Veritabanı (PostgreSQL)
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// 2. SignalR (Websocket Gerçek Zamanlı İletişim)
builder.Services.AddSignalR();

// 3. JWT Kimlik Doğrulama Ayarları
// GÜVENLİK İÇİN ŞİFRE GİZLENDİ:
var jwtKey = "BURAYA_EN_AZ_32_KARAKTERLIK_GIZLI_ANAHTAR_GELECEK"; 
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false; // HTTP üzerinden gelen token'lara izin verildi!
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    };
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ==========================================
// MİDDLEWARE (ARA KATMAN) BORU HATTI
// ==========================================

// 1. ZORUNLU STATİK DOSYA YÖNETİMİ (Klasör yoksa oluştur ve zorla dışa aç)
var staticFilePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
if (!Directory.Exists(staticFilePath))
{
    Directory.CreateDirectory(staticFilePath);
}

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(staticFilePath),
    RequestPath = ""
});

// 2. Ardından gelen isteğin kimliği doğrulanır (JWT Token kontrolü)
app.UseAuthentication();
app.UseAuthorization();

// 3. En son API uçlarına (Controller) ve WebSocket'e (SignalR) yönlendirilir
app.MapControllers();
app.MapHub<IzmirimCard.Api.Hubs.IzmirimHub>("/izmirimhub"); // SignalR Uç Noktası

app.Run();