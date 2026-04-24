<div align="center">

# Homelab 🏠

**A high-performance, native iOS dashboard for your self-hosted infrastructure.**
Zero Trust security · multi-process sync · a juicy UI powered by Metal shaders and neon gauges.

[![Platform](https://img.shields.io/badge/platform-iOS%2018%2B-black.svg?logo=apple)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5-orange.svg?logo=swift&logoColor=white)](https://swift.org)
[![Release](https://img.shields.io/github/v/release/MathieuDubart/homelab?sort=semver&label=release)](https://github.com/MathieuDubart/homelab/releases)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE.md)
[![TestFlight](https://img.shields.io/badge/TestFlight-join%20beta-0A84FF.svg?logo=apple)](https://testflight.apple.com/join/1ENGpuwn)
[![Made with SwiftUI](https://img.shields.io/badge/made%20with-SwiftUI-5E5CE6.svg?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)

</div>

---

## ✨ Features

- 🧭 **Full-Stack Monitoring** — real-time CPU / RAM / Docker stats via Glances & Coolify
- ⚡ **Interactive Control** — start / stop / restart services straight from native swipe actions
- 🗃 **TorBox Integration** — track and manage downloads with juicy, interactive rows
- 📱 **Smart Widgets** — multi-size widgets with interactive AppIntents for instant health checks from the Home Screen
- 🔐 **Secure by Design** — native support for Cloudflare Zero Trust (Service Tokens / mTLS)
- 🎨 **Juicy DA** — custom design system with Metal shaders, animated mesh backdrops, neon gauges, and tuned haptics

## 🧱 Architecture

- **Unified Storage** — centralized `StorageService` backed by App Groups, ensuring seamless data flow between the main app and widget extensions.
- **Network Resilience** — custom `URLRequest` builders with automatic header injection for Cloudflare-protected endpoints.
- **UX-First Logic** — a dedicated `DeletedTorrentsManager` handles asynchronous API deletions and prevents "ghost" data from surfacing.

## 🛠 Tech Stack

| Layer        | Stack                                                                   |
| ------------ | ----------------------------------------------------------------------- |
| UI           | SwiftUI · Metal shaders · custom design system (palette, typography, motion) |
| Concurrency  | Swift Concurrency (`async/await`, `Task`, actors)                       |
| Widgets      | WidgetKit + AppIntents (interactive widgets)                            |
| Persistence  | `UserDefaults` via App Groups                                           |
| Networking   | `URLSession` with Cloudflare Zero Trust (Service Tokens)                |
| Haptics      | Centralized `Haptics` helper around `sensoryFeedback` / `CHHapticEngine` |

## 🚀 Installation

### Requirements

- iOS **18.0** or later (iPhone XS / XR / 11-series and newer)
- A recent Xcode shipping an iOS 18+ SDK
- At least one of: **Glances**, **Coolify**, **TorBox** reachable from your device

### Option A — TestFlight *(easiest)*

→ Join the public beta: **<https://testflight.apple.com/join/1ENGpuwn>**

### Option B — Grab a release

→ Head to the [**Releases page**](https://github.com/MathieuDubart/homelab/releases) and pick the latest version.

### Option C — Build from source

```bash
git clone https://github.com/MathieuDubart/homelab.git
cd homelab
open Homelab.xcodeproj
```

→ Pick your signing team under **Signing & Capabilities**
→ Connect your iPhone or select a simulator
→ Press **⌘R**

## ⚙️ Configuration

Once launched, open **Settings** and fill in:

| Field                                   | Purpose                                                             |
| --------------------------------------- | ------------------------------------------------------------------- |
| Glances URL                             | Base URL of your Glances instance (CPU / RAM / Docker stats)        |
| Coolify URL + API Token                 | Endpoint and token for managing Coolify services                    |
| TorBox API Token                        | Authenticates the TorBox integration                                |
| Cloudflare Client ID & Secret *(opt.)*  | Service Token pair for Cloudflare Access–protected endpoints        |

The dashboard starts polling automatically once the URLs are saved.

## 🧠 Engineering Highlights

- **Zero Trust Architecture** — Cloudflare Access (mTLS / Service Tokens) secures internal APIs without compromising the mobile UX.
- **Multi-Process State Sync** — App Groups + custom `StorageService` keep a single source of truth between the main app and interactive widgets.
- **Optimistic UI & Ghost Data Handling** — custom logic masks API latency and phantom items for a zero-friction experience even with slow backends.

## 📜 License

Copyright © 2026 Mathieu Dubart

Homelab is free software, released under the **GNU General Public License, version 3 or (at your option) any later version** (`SPDX-License-Identifier: GPL-3.0-or-later`). You may use, study, share, and modify it under the terms of the GPL; derivative works must be released under the same license. See [`LICENSE.md`](LICENSE.md) for the full text.

---

<div align="center">

Built with ❤️ for the self-hosting community.

</div>
