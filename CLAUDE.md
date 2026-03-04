# app-starter-kit — Development Rules

> Production-ready mobile app starter: NestJS + iOS (SwiftUI) + Android (Compose).
> Magic link auth, design tokens, force update, offline-first.
> Built as a template — rename `AppStarterKit` / `starter.app` to your app when using.

---

## Tech Stack

| Platform | Language | UI | DB | Min Version |
|----------|----------|----|----|-------------|
| Backend API | TypeScript | NestJS 10 | PostgreSQL (Prisma 5) | Node 20+ |
| iOS | Swift | SwiftUI | Keychain | iOS 17.0 |
| Android | Kotlin | Jetpack Compose | Room | API 26 (Android 8.0) |

**Backend services:** Redis (BullMQ email queue) · Swagger at `/api/docs`

---

## Directory Structure

```
app-starter-kit/
├── backend/                  # NestJS API
│   ├── src/
│   │   ├── auth/             # Magic link: request + verify + refresh + logout
│   │   ├── user/             # GET /user/me, PATCH /user/me
│   │   ├── health/           # GET /health
│   │   ├── app-version/      # GET /app/version-check (force update)
│   │   └── prisma/           # Global PrismaService
│   ├── prisma/schema.prisma  # User, MagicLink, RefreshToken, UserPreferences, AppVersion
│   └── docker-compose.yml    # postgres:15 + redis:7
├── ios/
│   ├── project.yml           # XcodeGen — 3 schemes: Dev, Staging, Release
│   ├── Configs/              # xcconfig per scheme (API_BASE_URL, ENVIRONMENT)
│   └── AppStarterKit/
│       ├── App/              # AppStarterKit.swift, AppState.swift, RootView.swift
│       ├── Features/Auth/    # WelcomeView, EmailInputView, CodeEntryView (8-digit)
│       ├── Features/Home/    # HomeView placeholder
│       ├── DesignSystem/     # AppTokens.swift, AppButton, AppCard, AppTextField, etc.
│       └── Core/             # APIClient, NetworkMonitor, KeychainHelper, NFRs
├── android/
│   └── app/src/main/kotlin/com/starter/app/
│       ├── app/              # AppStarterKit (Hilt), MainActivity
│       ├── features/auth/    # AuthNavHost, AuthViewModel, screens (Welcome → Email → Code)
│       ├── features/home/    # HomeScreen placeholder
│       ├── design/           # AppTokens, AppButton, AppCard, AppTextField, etc.
│       ├── core/             # ApiClient, NetworkMonitor, SecurePreferences, AppDatabase, DI
│       └── nfr/              # ForceUpdateViewModel, ForceUpdateComponents, ReviewManager
├── sentinel/schemas/         # Design tokens, feature flags (source of truth)
├── docs/setup/               # Setup guides (GitHub Actions, deployment, etc.)
└── .github/workflows/        # CI templates (manual trigger only — see docs/setup/GITHUB_ACTIONS.md)
```

---

## Platform Naming (Never Deviate)

| Platform | Directory | In code |
|----------|-----------|---------|
| Backend API | `backend/` | API |
| iOS | `ios/` | iOS |
| Android | `android/` | Android |

---

## Auth Flow

Magic link with 8-digit OTP. Never passwords.

```
POST /api/v1/auth/magic-link/request  { email }
  → generates 8-digit code, stores MagicLink (15min expiry), queues email job

POST /api/v1/auth/magic-link/verify   { email, code }
  → marks MagicLink used, returns { accessToken (15m), refreshToken (30d), user }

POST /api/v1/auth/refresh             { refreshToken }
  → returns { accessToken }

POST /api/v1/auth/logout              { refreshToken }  [requires JWT]
  → revokes RefreshToken
```

Token storage:
- **iOS**: Keychain via `KeychainHelper`
- **Android**: `EncryptedSharedPreferences` via `SecurePreferences`

---

## Coding Conventions

### Backend (TypeScript / NestJS)
- Module-per-domain architecture
- Prisma for all DB access — no raw SQL
- `class-validator` + `class-transformer` on all DTOs
- `ConfigModule.forRoot({ isGlobal: true })` — env vars via `process.env`
- Never commit `.env` — only `.env.example`

### iOS (Swift / SwiftUI)
- MVVM with `@Observable` macro
- `@Environment` for DI (AppState passed down from root)
- `async/await` everywhere — no Combine
- All tokens from `AppTokens` — never hardcode colours or sizes
- URLProtocol for test-time HTTP interception (see `AppStarterKitTests/Helpers/MockURLProtocol.swift`)

### Android (Kotlin / Compose)
- MVVM with `ViewModel` + `StateFlow`
- Hilt for DI throughout
- Coroutines + Flow — no RxJava
- All tokens from `AppColors` / `AppSpacing` / `AppRadius`
- MockWebServer for test-time HTTP interception

---

## NFRs

### Force Update
- Backend: `GET /api/v1/app/version-check?platform=ios&version=1.0.0`
- Returns `{ isUpdateRequired, isUpdateRecommended, minimumVersion, latestVersion }`
- iOS: `ForceUpdateChecker` → `HardUpdateView` (blocking) or `SoftUpdateBanner` (dismissable)
- Android: `ForceUpdateViewModel` → `HardUpdateScreen` or `SoftUpdateBanner`
- **Silent on failure** — a failed version check never blocks the user

### Offline Indicator
- iOS: `NetworkMonitor` (NWPathMonitor) → `OfflineBanner` overlay
- Android: `NetworkMonitor` (ConnectivityManager Flow) → `OfflineBanner` composable
- Auto-dismisses when connectivity restored

### App Review Prompt
- iOS: `ReviewManager` → `SKStoreReviewController.requestReview`
- Android: `ReviewManager` → Play In-App Review API
- 7-day cooldown between prompts — stored in `UserDefaults` / `SharedPreferences`

---

## Build Environments

Three environments on every platform:

| Env | iOS Scheme | Android Flavour |
|-----|-----------|-----------------|
| Dev | AppStarterKit-Dev | dev |
| Staging | AppStarterKit-Staging | staging |
| Prod | AppStarterKit-Release | prod |

API URLs set in xcconfig (iOS) and `buildConfigField` (Android).

---

## CI/CD

Workflow files in `.github/workflows/` use **manual trigger only** (`on: workflow_dispatch`).
See `docs/setup/GITHUB_ACTIONS.md` to activate automatic runs and add secrets.

---

## Renaming for a New Project

When using this as a template:

1. Find/replace `AppStarterKit` → your app name
2. Find/replace `starter.app` → your bundle ID prefix
3. Find/replace `com.appstarterkit.app` → your Android package name
4. Update colours in `AppTokens.swift` (iOS) and `AppTokens.kt` (Android)
5. Update API URLs in xcconfig files and `build.gradle.kts`
6. Replace `YOUR_APP_ID` in `HardUpdateView.swift` / `ForceUpdateComponents.kt` with real App Store / Play Store IDs
7. Implement `email.processor.ts` with real SMTP or transactional email provider (Postmark, Resend, SendGrid)

---

## Testing

### iOS
- `URLProtocol` mock infra: `AppStarterKitTests/Helpers/MockURLProtocol.swift`
- Register with `URLProtocol.registerClass(MockURLProtocol.self)` in test setUp

### Android
- `MockWebServer` for HTTP interception
- `MockK` for unit mocking
- JUnit5 for all tests

### Backend
- `Jest` + `@nestjs/testing` for unit tests
- Supertest for endpoint tests

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `backend/prisma/schema.prisma` | DB schema — User, MagicLink, RefreshToken, UserPreferences, AppVersion |
| `backend/src/auth/auth.service.ts` | Magic link logic |
| `backend/.env.example` | All required environment variables |
| `ios/project.yml` | XcodeGen project definition |
| `ios/Configs/*.xcconfig` | Per-environment config (API URL, bundle ID) |
| `ios/AppStarterKit/Core/NFR/` | Force update, offline banner, review prompt |
| `android/gradle/libs.versions.toml` | All Android dependency versions |
| `android/app/build.gradle.kts` | Flavour definitions |
| `android/app/src/main/kotlin/.../nfr/` | Force update, offline banner, review prompt |
| `sentinel/schemas/design/tokens.json` | Design token source of truth |
| `docs/setup/GITHUB_ACTIONS.md` | CI setup guide |
