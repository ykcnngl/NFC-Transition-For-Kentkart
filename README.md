# 🚌 İzmirim NFC Simulator & Smart City Assistant

A production-grade, full-stack transit companion and NFC emulator developed during my software engineering internship at **Ünibel A.Ş.** (İzmir Metropolitan Municipality IT Subsidiary).

NFC Host Card Emulation · AI-Powered City Guide · 3D Simulations · Real-Time WebSockets

<br>

🌍 **Technical Showcase:** This repository serves as a technical showcase of the engineering decisions, system architecture, and UI/UX design. I welcome code walkthroughs in interview settings. 
*(Note: Sensitive data such as API keys, SMTP passwords, and DB connection strings have been scrubbed for security.)*

## 🧭 What Is This?

İzmirim NFC Simulator is a full-stack mobile platform that digitizes physical public transportation cards into secure mobile wallets. Moving beyond a simple payment app, it functions as an intelligent city companion by integrating a 3D transit simulation environment and a context-aware AI assistant.

The system processes real-time hardware signals using **Host Card Emulation (HCE)** on the frontend, while a robust **C# ASP.NET Core** backend orchestrates secure transactions, real-time WebSocket communication, and Google Gemini AI integrations via an isolated Docker network.

## ✨ Feature Highlights

| Feature | Description |
| :--- | :--- |
| 📳 **NFC/HCE Emulation** | Digitizes physical transport cards by overriding native NFC hardware to emit custom APDU commands. |
| 🧠 **AI City Assistant** | Gemini AI integration for smart city routing and answering user queries regarding İzmir's transit network. |
| ⚡ **Single-Session Enforcement** | Real-time WebSocket connection to instantly kick out concurrent logins across different devices (ForceLogout). |
| 🧊 **3D Turnstile Simulation** | Interactive turnstile passing animations rendered at 60fps using Three.js inside the Flutter view. |
| 🔐 **Secure Onboarding** | JWT-based authentication combined with Google SMTP-powered OTP email verification and Bcrypt hashing. |
| 🌙 **Glassmorphism UI** | A highly polished, context-aware interface featuring dynamic light/dark modes and blurred glass effects. |

## 🏗️ System Architecture

```text
╔══════════════════════════════════════════════════════════════╗
║                    Flutter Mobile Client                     ║
║                                                              ║
║  ┌─────────────┐  ┌──────────────────────────────────────┐   ║
║  │ Glass UI    │  │     Hardware & Rendering Layer       │   ║
║  │ State Mgmt  │◄─│  NFC/HCE Service  ·  Three.js Engine │   ║
║  │ QR / Maps   │  │  (APDU Commands)     (InAppWebView)  │   ║
║  └──────┬──────┘  └──────────────────────────────────────┘   ║
╚─────────┼────────────────────────────────────────────────────╝
          │ 
          │ HTTPS / REST (JWT)  &  TCP (SignalR WebSockets)
          ▼
╔══════════════════════════════════════════════════════════════╗
║                   C# ASP.NET Core Backend                    ║
║                                                              ║
║  ┌───────────────────┐    ┌──────────────────────────────┐   ║
║  │   Auth & OTP Svc  │    │      SignalR Hub (WSS)       │   ║
║  │  (Google SMTP)    │    │      (ForceLogout Auth)      │   ║
║  └───────────────────┘    └──────────────────────────────┘   ║
║  ┌───────────────────────────────────────────────────────┐   ║
║  │                   Gemini AI Engine                    │   ║
║  └───────────────────────────────────────────────────────┘   ║
╚═════════════╦══════════════════════════════════╦═════════════╝
              │                                  │
    Internal  │  Docker Bridge Network           │  External
              ▼                                  ▼
      ┌───────────────┐                  ┌───────────────┐
      │  PostgreSQL   │                  │  Google APIs  │
      │ (Isolated DB) │                  │ (AI & Email)  │
      └───────────────┘                  └───────────────┘

## 🧠 Hard Engineering Problems Solved

<table>
  <thead>
    <tr>
      <th>Engineering Challenge</th>
      <th>Problem & Solution</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="25%">📳 <b>Hardware-Level NFC Interception</b></td>
      <td><b>The Problem:</b> Modern Android devices prioritize Google Wallet or default banking apps when approaching an NFC reader, making custom transit card emulation difficult.<br><br><b>The Solution:</b> Implemented a foreground Host Card Emulation (HCE) service in the Android Manifest (<code>android.nfc.cardemulation.host_apdu_service</code>) that listens for specific Application Protocol Data Unit (APDU) commands. This forces the OS to route the physical turnstile's NFC signal directly to the Flutter app's payload.</td>
    </tr>
    <tr>
      <td>⚡ <b>Multi-Device Session Hijacking</b></td>
      <td><b>The Problem:</b> Users could potentially log into the same digital transit card from multiple devices simultaneously, leading to race conditions in balance deduction and security flaws.<br><br><b>The Solution:</b> Integrated <b>SignalR WebSockets</b> to maintain a persistent full-duplex TCP connection. When a new login occurs, the backend identifies the previous <code>ConnectionId</code> associated with that user and emits a real-time <code>ForceLogout</code> event, instantly clearing the SharedPreferences and terminating the session on the old device.</td>
    </tr>
    <tr>
      <td>🛡️ <b>Database Vulnerability</b></td>
      <td><b>The Problem:</b> Exposing the PostgreSQL database port (5432) to the internet for backend connectivity poses severe risks of brute-force attacks and SQL injections.<br><br><b>The Solution:</b> Utilized <b>Docker Containerization</b> with an isolated <b>Bridge Network</b>. The ASP.NET Core API and PostgreSQL database run in the same virtual network. The API accesses the database via an internal IP, keeping the database completely invisible and inaccessible from the outside world (Zero Trust Architecture).</td>
    </tr>
    <tr>
      <td>🧊 <b>60 FPS 3D Rendering</b></td>
      <td><b>The Problem:</b> Rendering complex 3D turnstile animations directly in Flutter using native packages drastically increased the APK size and caused frame drops on low-end devices.<br><br><b>The Solution:</b> Offloaded the heavy lifting to the GPU by writing the 3D scene in <b>Three.js</b> (WebGL) and injecting it into the app via a transparent, hardware-accelerated <code>InAppWebView</code>. This decoupled the rendering logic from the UI thread, ensuring smooth 60fps performance with minimal bundle size impact.</td>
    </tr>
  </tbody>
</table>

## 🛠️ Full Tech Stack

<table>
  <thead>
    <tr>
      <th>Category</th>
      <th>Technology</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>📱 <b>Mobile Frontend</b></td>
      <td>Flutter, Dart, SharedPreferences</td>
    </tr>
    <tr>
      <td>🎛️ <b>Hardware & UI</b></td>
      <td>NFC/HCE Android APIs, Three.js (WebGL), Glassmorphism</td>
    </tr>
    <tr>
      <td>⚙️ <b>Backend API</b></td>
      <td>C# 8.0, ASP.NET Core, N-Tier Architecture</td>
    </tr>
    <tr>
      <td>📡 <b>Real-Time & AI</b></td>
      <td>SignalR (WebSockets), Google Gemini AI API</td>
    </tr>
    <tr>
      <td>🗄️ <b>Database</b></td>
      <td>PostgreSQL, Entity Framework Core (EF Core)</td>
    </tr>
    <tr>
      <td>🔐 <b>Security</b></td>
      <td>JWT Authentication, Bcrypt Hashing, Google SMTP (OTP)</td>
    </tr>
    <tr>
      <td>☁️ <b>Infrastructure</b></td>
      <td>Docker, Docker Bridge Networking</td>
    </tr>
  </tbody>
</table>
