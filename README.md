# 🚌 İzmirim NFC Simülatör & Akıllı Şehir Asistanı

**Ünibel A.Ş.** (İzmir Büyükşehir Belediyesi Bilgi İşlem İştiraki) bünyesinde gerçekleştirilen yazılım mühendisliği stajı kapsamında geliştirilmiş, üretime hazır (production-grade), uçtan uca bir ulaşım asistanı ve NFC emülatörü.

NFC Host Card Emulation · Yapay Zeka Destekli Şehir Rehberi · 3D Simülasyonlar · Gerçek Zamanlı WebSockets

<br>

🌍 **Teknik Vitrin:** Bu depo, staj sürecim boyunca aldığım mühendislik kararlarının, sistem mimarisinin ve UI/UX tasarımının teknik bir gösterimi olarak kurgulanmıştır. Teknik mülakat süreçlerinde kod mimarisi üzerine yapacağımız incelemelere (code walkthroughs) açığım. 
*(Not: API anahtarları, SMTP şifreleri ve veritabanı bağlantı dizeleri gibi hassas veriler siber güvenlik politikaları gereği projeden temizlenmiştir.)*

## 📸 Ekran Görüntüleri

*(Ekran görüntülerini GitHub editörüne sürükleyip bırakarak yükleyin ve oluşturulan bağlantıları buraya yapıştırın.)*

## 🧭 Bu Proje Nedir?

İzmirim NFC Simülatörü, fiziksel toplu taşıma kartlarını güvenli mobil cüzdanlara dönüştüren uçtan uca (full-stack) bir mobil platformdur. Basit bir ödeme uygulamasının ötesine geçerek; 3D turnike simülasyon ortamı ve bağlamın farkında olan bir yapay zeka asistanı entegrasyonu ile "Akıllı Şehir Rehberi" olarak işlev görür.

Sistem, ön yüzde **Host Card Emulation (HCE)** kullanarak donanım seviyesinde gerçek zamanlı sinyalleri işlerken; arka planda sağlam bir **C# ASP.NET Core** mimarisi ile güvenli işlemleri, gerçek zamanlı WebSocket iletişimini ve izole edilmiş bir Docker ağı üzerinden Google Gemini AI entegrasyonlarını yönetir.

## ✨ Öne Çıkan Özellikler

| Özellik | Açıklama |
| :--- | :--- |
| 📳 **NFC/HCE Emülasyonu** | Özel APDU komutları yaymak için cihazın yerel NFC donanımını geçersiz kılarak fiziksel kartları dijitalleştirir. |
| 🧠 **Yapay Zeka (AI) Asistanı** | Akıllı şehir rotalaması ve İzmir'in ulaşım ağıyla ilgili soruları yanıtlamak için Gemini AI entegrasyonu. |
| ⚡ **Tekli Oturum Yönetimi** | Farklı cihazlar üzerinden yapılan eşzamanlı girişleri anında sonlandırmak için (ForceLogout) gerçek zamanlı WebSocket bağlantısı. |
| 🧊 **3D Turnike Simülasyonu** | Flutter görünümü içinde Three.js kullanılarak 60fps hızında render edilen interaktif turnike geçiş animasyonları. |
| 🔐 **Güvenli Kimlik Doğrulama** | Google SMTP destekli OTP e-posta doğrulaması ve Bcrypt şifreleme ile birleştirilmiş JWT tabanlı güvenlik mimarisi. |
| 🌙 **Glassmorphism Arayüz** | Dinamik aydınlık/karanlık modları ve bulanık cam efektleri içeren, modern ve bağlama duyarlı bir UI tasarımı. |

## 🏗️ Sistem Mimarisi

```text
╔══════════════════════════════════════════════════════════════╗
║                    Flutter Mobil İstemci                     ║
║                                                              ║
║  ┌─────────────┐  ┌──────────────────────────────────────┐   ║
║  │ Glass UI    │  │       Donanım ve Render Katmanı      │   ║
║  │ State Mgmt  │◄─│  NFC/HCE Servisi  ·  Three.js Motoru │   ║
║  │ QR / Maps   │  │  (APDU Komutları)    (InAppWebView)  │   ║
║  └──────┬──────┘  └──────────────────────────────────────┘   ║
╚─────────┼────────────────────────────────────────────────────╝
          │ 
          │ HTTPS / REST (JWT)  &  TCP (SignalR WebSockets)
          ▼
╔══════════════════════════════════════════════════════════════╗
║                   C# ASP.NET Core Arka Uç                    ║
║                                                              ║
║  ┌───────────────────┐    ┌──────────────────────────────┐   ║
║  │   Auth & OTP Svc  │    │      SignalR Hub (WSS)       │   ║
║  │  (Google SMTP)    │    │   (Force Logout Protokolü)   │   ║
║  └───────────────────┘    └──────────────────────────────┘   ║
║  ┌───────────────────────────────────────────────────────┐   ║
║  │                   Gemini AI Motoru                    │   ║
║  └───────────────────────────────────────────────────────┘   ║
╚═════════════╦══════════════════════════════════╦═════════════╝
              │                                  │
      İç Ağ   │  Docker Bridge Network           │  Dış Ağ
              ▼                                  ▼
      ┌───────────────┐                  ┌───────────────┐
      │  PostgreSQL   │                  │  Google API's │
      │ (İzole DB)    │                  │ (AI ve E-Posta)│
      └───────────────┘                  └───────────────┘
