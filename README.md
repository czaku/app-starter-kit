# app-starter-kit

Production-ready mobile app starter: **NestJS API + iOS (SwiftUI) + Android (Compose)**.

Magic link auth, design tokens, offline indicator, force update, review prompt — all wired up and ready to restyle.

---

## Stack

| Platform | Language | UI | DB | Auth |
|----------|----------|----|----|------|
| Backend | TypeScript | NestJS 10 | PostgreSQL (Prisma 5) | Magic link + JWT |
| iOS | Swift | SwiftUI + SwiftData | — | KeychainHelper |
| Android | Kotlin | Jetpack Compose | Room | EncryptedSharedPreferences |

**Backend services:** Redis (BullMQ email queue) · Swagger at `/api/docs`

---

## Quick Start

### 1. Clone and rename

```bash
# Use this repo as a GitHub template, then:
find . -type f \( -name "*.swift" -o -name "*.kt" -o -name "*.ts" -o -name "*.json" -o -name "*.gradle.kts" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.xml" -o -name "*.xcconfig" -o -name "*.plist" \) \
  -exec sed -i '' 's/AppStarterKit/MyApp/g; s/starter\.app/myapp/g; s/app-starter-kit/my-app/g' {} \;
```

### 2. Backend

```bash
cd backend
cp .env.example .env          # fill in DATABASE_URL, JWT_SECRET, REDIS_URL
docker-compose up -d          # starts postgres:15 + redis:7
npm install
npx prisma migrate dev        # creates tables
npx prisma db seed            # seeds AppVersion rows
npm run start:dev             # http://localhost:3000/api/v1
# Swagger UI: http://localhost:3000/api/docs
```

### 3. iOS

```bash
cd ios
brew install xcodegen         # if not installed
xcodegen generate             # generates AppStarterKit.xcodeproj
open AppStarterKit.xcodeproj
# Select scheme AppStarterKit-Dev and run
```

### 4. Android

```bash
cd android
./gradlew assembleDevDebug    # builds dev debug APK
# Or open in Android Studio and run with dev flavour
```

---

## Architecture

### Auth flow (all platforms)

```
WelcomeScreen
    ↓ "Get Started"
EmailInputScreen → POST /auth/magic-link/request
    ↓ receives 8-digit code by email
CodeEntryScreen  → POST /auth/magic-link/verify
    ↓ receives JWT + refresh token
HomeScreen
```

The 8-digit OTP is generated server-side with `crypto.randomInt`, stored in `magic_links` table with a 15-minute expiry. JWT access tokens expire in 15 minutes; refresh tokens last 30 days.

### NFRs included

| Feature | iOS | Android | Backend |
|---------|-----|---------|---------|
| Force update (hard) | HardUpdateView (full-screen, undismissable) | HardUpdateScreen | GET /app/version-check |
| Force update (soft) | SoftUpdateBanner (dismissable) | SoftUpdateBanner | GET /app/version-check |
| Offline indicator | OfflineBanner (NWPathMonitor) | OfflineBanner (ConnectivityManager) | — |
| App review prompt | ReviewManager (SKStoreReviewController) | ReviewManager (Play In-App Review) | — |

### Design tokens

All colours, spacing, and radius values live in `AppTokens` (iOS) and `AppColors/AppSpacing/AppRadius` (Android). To restyle for a new project, change the values there — every component inherits them.

---

## Environments

Three environments on every platform:

| Env | iOS Scheme | Android Flavour | API URL |
|-----|-----------|-----------------|---------|
| Dev | AppStarterKit-Dev | dev | `http://localhost:3000/api/v1` (iOS: `http://10.0.2.2:3000/api/v1` Android) |
| Staging | AppStarterKit-Staging | staging | `https://api-staging.yourapp.com/api/v1` |
| Production | AppStarterKit-Release | prod | `https://api.yourapp.com/api/v1` |

Update the URLs in `ios/Configs/*.xcconfig` and `android/app/build.gradle.kts`.

---

## Project structure

```
app-starter-kit/
├── backend/                  # NestJS API
│   ├── src/
│   │   ├── auth/             # Magic link auth
│   │   ├── user/             # User profile
│   │   ├── health/           # GET /health
│   │   ├── app-version/      # Force update check
│   │   └── prisma/           # PrismaService (global)
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── seed.ts
│   └── docker-compose.yml
├── ios/
│   ├── project.yml           # XcodeGen config
│   ├── Configs/              # xcconfig per env
│   └── AppStarterKit/
│       ├── App/              # Entry point, RootView, AppState
│       ├── Features/Auth/    # Auth flow (Welcome → Email → Code)
│       ├── Features/Home/    # Home placeholder
│       ├── DesignSystem/     # Tokens + Components
│       └── Core/             # APIClient, NetworkMonitor, KeychainHelper, NFRs
├── android/
│   ├── app/src/main/
│   │   └── kotlin/com/starter/app/
│   │       ├── app/          # Application + MainActivity
│   │       ├── features/     # Auth + Home
│   │       ├── design/       # Tokens + Components
│   │       ├── core/         # Network, Storage, DB, DI
│   │       └── nfr/          # ForceUpdate, ReviewManager
│   └── gradle/libs.versions.toml
├── sentinel/                 # Schema source of truth
│   └── schemas/
├── docs/
│   └── setup/
│       └── GITHUB_ACTIONS.md # CI setup guide
└── .github/workflows/        # Workflow templates (manual trigger only)
```

---

## Customising for a new project

1. **Rename**: find/replace `AppStarterKit` → your app name, `starter.app` → your bundle ID
2. **Colours**: update `AppTokens.Color.primary` (iOS) and `AppColors.Primary` (Android)
3. **Backend URL**: update xcconfig files and `buildConfigField` in build.gradle.kts
4. **App Store / Play Store links**: search for `YOUR_APP_ID` and `com.appstarterkit.app` in NFR files
5. **Email template**: implement `email.processor.ts` with your SMTP or transactional email provider
6. **Extend auth**: add user profile fields to Prisma schema + User module

---

## CI/CD

Workflow templates are in `.github/workflows/` with **manual trigger only** (`on: workflow_dispatch`).
See `docs/setup/GITHUB_ACTIONS.md` for full setup instructions.

To activate automatic runs, add `push` / `pull_request` triggers to each workflow file.

---

## What's included

### Platform foundations
- [x] iOS: SwiftUI + `@Observable` MVVM, SwiftData-ready, iOS 17+
- [x] Android: Jetpack Compose + ViewModel + StateFlow, API 26+
- [x] Backend: NestJS + Prisma + PostgreSQL + BullMQ + Redis

### Authentication
- [x] Magic link (email OTP) — no passwords
- [x] JWT + refresh tokens with auto-rotation
- [x] Token refresh interceptor (auto-retry on 401)
- [x] Logout (client + server-side token revocation)
- [x] Keychain (iOS) + EncryptedSharedPreferences (Android) storage
- [x] Biometric auth (Face ID / Touch ID / Fingerprint)
- [x] Deeplink handler for magic link tap-to-login

### Design system
- [x] Sentinel-generated design tokens (colors, spacing, typography, radius)
- [x] AppButton, AppCard, AppTextField, EmptyState, LoadingView
- [x] Toast / Snackbar feedback system
- [x] Shimmer skeleton loading
- [x] Haptics helper (iOS)
- [x] Dark mode ready

### NFRs
- [x] Offline banner (connectivity detection)
- [x] Force update + soft update banners (Firebase Remote Config compatible)
- [x] In-app review prompt (SKStoreReviewController / ReviewManager)
- [x] Crashlytics stub (Firebase, ready to configure)

### Backend
- [x] Magic link auth with BullMQ email queue + SMTP
- [x] Rate limiting (@nestjs/throttler)
- [x] OpenAPI / Swagger docs at /api/docs
- [x] Config validation (fail-fast on missing env vars)
- [x] Push notification stub module (FCM-ready)
- [x] App version enforcement endpoint

### Developer experience
- [x] Sentinel schema validation + code generation
- [x] Claude Code hooks (block generated files, dangerous git)
- [x] `scripts/rename.sh` — one-command project rename
- [x] Fixture-driven tests (MockURLProtocol + MockWebServer)
- [x] Backend E2E tests + contract validation
- [x] Fastlane (iOS TestFlight + Android Play Store)
- [x] GitHub Actions (backend + iOS + Android CI)
- [x] Dependabot for automated dependency updates
- [x] Pre-commit hook for schema validation
