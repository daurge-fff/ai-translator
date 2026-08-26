<div align="center">

# Contextual AI Translator

### Cross-platform translator that understands context — powered by Liquid Glass UI

Translate text for the right audience and situation. The AI understands *who* you're writing to and *why*, so a "football" for an American becomes "soccer", and every message sounds natural. It translates — it never chats back.

![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)
![PRs](https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge)
![Platforms](https://img.shields.io/badge/iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Web-000000?style=for-the-badge)

</div>

---

## ✨ What's inside

**Native iOS 26 Liquid Glass design language** — a floating frosted navigation bar with spring physics, glass panels, adaptive light/dark material, and full Dynamic Island edge-to-edge scrolling.

- 🧠 **Context-aware translation** — describe the situation; the model adapts tone, vocabulary and regional dialect (US / UK / AU / CA).
- 🌍 **100+ languages** with native names and search.
- 📝 **Context templates** — save reusable "situations" (colleague, boss, client…) and apply them in one tap.
- 🕘 **Translation history** stored locally in SQLite (Drift), with instant search.
- 🔒 **Security-first proxy** — Node.js API with rate limiting, prompt-injection filtering and admin ban/incident tooling.
- 🪪 **Real Google Sign-In** (OAuth 2.0).
- 🌗 **Light / Dark / System themes** + 5 accent colors.
- 🌐 **Bilingual**: English (default) and Russian.

## 📸 Screenshots

| Login | Translate | Profile |
|:-----:|:---------:|:-------:|
| *Pulsing liquid glass hero* | *Contextual translator* | *Theme picker & privacy* |

> Place real screenshots in `docs/screenshots/` and reference them here.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter Client                      │
│  ┌──────────┐ ┌──────────┐ ┌───────────┐ ┌──────────────┐  │
│  │ Translate│ │ Contexts │ │  History  │ │   Profile    │  │
│  └────┬─────┘ └────┬─────┘ └─────┬─────┘ └──────┬───────┘  │
│       └────────────┴──────┬──────┴──────────────┘          │
│                  Liquid Glass Navigation Bar                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │   presentation (screens, widgets, sheets, dialogs)   │  │
│  │   providers (Riverpod) │ data (Dio, Drift, gSignIn)  │  │
│  │   core (theme, l10n, constants)                      │  │
│  └──────────────────────────┬───────────────────────────┘  │
└─────────────────────────────┼─────────────────────────────┘
                              │ HTTPS
┌─────────────────────────────┼─────────────────────────────┐
│                      Node.js API (Express)                │
│  rate-limit → auth → injection-filter → DeepSeek proxy    │
│  admin incidents & ban lists (MongoDB / in-memory)        │
└────────────────────────────────────────────────────────────┘
```

- **Flutter** — cross-platform UI, Riverpod for state, Dio for HTTP, Drift for local DB.
- **Node.js / Express** — secure proxy to DeepSeek; never exposes the model key to clients.
- **MongoDB** — optional persistence for bans & incidents (graceful in-memory fallback).

## 🛠️ Tech stack

| Layer | Tools |
|-------|-------|
| UI | Flutter, Cupertino, Liquid Glass components |
| State | Riverpod (StateNotifier) |
| Local data | Drift (SQLite) |
| Networking | Dio |
| Auth | google_sign_in (OAuth 2.0) |
| Backend | Node.js, Express, express-rate-limit, mongoose |
| AI | DeepSeek (via proxy) |
| L10n | Custom `AppStrings` (EN default / RU) |

## 📁 Project structure

```
app/
├── lib/
│   ├── core/            # theme, l10n, constants, device
│   ├── data/            # remote API, local DB
│   ├── presentation/    # screens, widgets, sheets
│   └── providers/       # Riverpod state
├── server/              # Node.js API proxy
├── mockups/             # interactive HTML prototypes
└── test/                # widget tests
```

## ✅ Requirements

- Flutter SDK **3.27+** (developed on 3.44)
- Dart **3.2+**
- Xcode + CocoaPods (iOS/macOS)
- Android SDK Command-line Tools
- Node.js **20+** (for the server)
- Docker Desktop *(optional — MongoDB)*
- Google Cloud OAuth **Client ID** for Android / iOS / Web
- DeepSeek **API key** — stored only in `server/.env`

## 🚀 Getting started

```bash
# 1. Install dependencies
cd app && flutter pub get

# 2. Run the API proxy
cd server
cp .env.example .env          # add DEEPSEEK_API_KEY
npm install
npm run dev                   # → http://localhost:3000

# 3. Configure Google Sign-In
#    Full guide (incl. testing mode for unpublished apps):
#    → docs/GOOGLE_SIGN_IN_SETUP.md
#    - iOS:    add GoogleService-Info.plist to ios/Runner
#    - Android: add google-services.json + SHA-1 fingerprint

# 4. Launch the app
cd app && flutter run
```

> The API base URL auto-adapts: `10.0.2.2:3000` on the Android emulator,
> `127.0.0.1:3000` on iOS simulator & desktop.

## 🌐 Localization

| Code | Language | Default |
|------|----------|---------|
| `en` | English | ✅ |
| `ru` | Русский | – |

All user-facing strings live in `lib/core/l10n/app_strings.dart`.
Add a new locale by adding its strings and registering it in `lib/core/l10n/locale_provider.dart` + `main.dart`.

## 🗺️ Roadmap

- [x] Liquid Glass design system & floating nav bar
- [x] Context-aware translation + templates
- [x] Local history with search
- [x] Real Google Sign-In
- [x] EN/RU localization
- [x] Security proxy: rate limiting, injection filter, admin bans
- [ ] Offline translation cache & queue
- [ ] Cloud sync of history across devices
- [ ] More locales (ES, DE, FR)
- [ ] Widget tests for all screens

## 📜 License

MIT — see [LICENSE](LICENSE) for details.

<div align="center">

**Made with 💙 — Contextual Translator**

</div>
