# 1. Derleme Aşaması (SDK)
# Not: Terminal loglarında .NET 10 kullandığını gördüğüm için versiyonu 10.0 yaptık
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Proje dosyasını kopyala ve paketleri (NuGet) yükle
COPY ["IzmirimCard.Api.csproj", "./"]
RUN dotnet restore "./IzmirimCard.Api.csproj"

# Tüm kodları kopyala ve Release modunda derle
COPY . .
RUN dotnet build "IzmirimCard.Api.csproj" -c Release -o /app/build
RUN dotnet publish "IzmirimCard.Api.csproj" -c Release -o /app/publish

# 2. Çalıştırma Aşaması (Sadece Runtime - Daha hafif bir imaj için)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "IzmirimCard.Api.dll"]