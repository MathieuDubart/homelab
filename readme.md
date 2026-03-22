# Homelab 🏠

A lightweight, native iOS dashboard to monitor and control your self-hosted Coolify

## Features

- **Full Stack Monitoring**: Real-time CPU/RAM/Docker stats via Glances & Coolify.
- **Interactive Contro**l: Start/Stop/Restart services with native Swipe Actions.
- **TorBox Integration**: Advanced storage management with interactive download controls.
- **Smart Widgets**: Multi-size interactive widgets for instant system health checks.
- **Secure by Design**: Native support for Cloudflare Zero Trust (Service Tokens).

## Architecture & Engineering

- **Unified Storage**: A centralized StorageService managing App Group persistence, ensuring seamless data flow between the App and Widget extensions.
- **Network Resilience**: Custom URLRequest builders with automatic header injection for secured endpoints.
- **UX-First Logic**: Implementation of a DeletedTorrentsManager to handle asynchronous API deletions and prevent "ghost" data display.

## Installation
### 1. Get the latest release

  → Go to the [Releases page](https://github.com/MathieuDubart/homelab/releases), download the latest release version and go to step 2 **OR** download the app on [Testflight](https://testflight.apple.com/join/1ENGpuwn).
  
### 2. Build & Run

  → Connect your iPhone via USB or select a Simulator.
  
  → Ensure your Team is selected in Signing & Capabilities.
  
  → Press Cmd + R to build and run.

## Configuration

### Once the app is launched:
  
  → Enter your Glances URL in the settings.
  
  → Paste your Coolify URL & API Token.

  → Paste your TorBox API Token.

  → Paste your Cloudflare Client ID & Secret if you're using Cloudflare Access to protect your Glances/Coolify services
  
  → The dashboard will automatically start polling data.

### Tech Stack

  → SwiftUI & Swift Concurrency: Leveraging async/await and Task for non-blocking network operations.

  → WidgetKit (iOS 17+): Interactive widgets using AppIntents for direct infrastructure control from the Home Screen.

  → Cloudflare Zero Trust: Programmatic bypass of SSO via Service Tokens.

  → Persistent Storage: Unified UserDefaults via App Groups for cross-target data sharing.

### Engineering Challenges
  → Zero Trust Architecture: Implementation of Cloudflare Access (mTLS/Service Tokens) to secure internal APIs without compromising the mobile experience.

  → Multi-Process State Sync: Use of App Groups and custom StorageService to maintain a single source of truth between the main App and interactive Home Screen Widgets.

  → Optimistic UI & Ghost Data Handling: Custom logic to manage API latency and "phantom" items, ensuring a "Zero Friction" user experience even with slow backend responses.

Built with ❤️ for the self-hosting community.
