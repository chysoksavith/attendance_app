# AGENTS.md — Attendance Mobile App

Single source of truth for all AI agents working on this Flutter mobile app.
Do not fork — edit this file only.

---

## 0. Operating Principles

- **Read before write**: read the actual file/widget before changing it.
- **Root-cause over patching**: fail twice → stop, diagnose, propose a different approach.
- **Scope discipline**: solve only what was asked. No bundled refactors.
- **Verify before done**: `flutter analyze` + `flutter build` after every change.
- **Consult the workspace AGENTS.md** at `../AGENTS.md` for cross-repo integration rules.
- **Consult the ERP Second Brain** at `../erp-system/obsidian-vault/` for backend API contracts.

---

## 1. Project Overview

**Attendance Mobile** — a Flutter app for employees to:
- Clock in/out with GPS + photo verification
- Submit leave requests (synced to ERP's Leave Management module)
- View attendance history and reports
- Receive push notifications for reminders

**Backend**: connects to the ERP system's API (`/api/v1/`) via Laravel Sanctum tokens.
See `../erp-system/AGENTS.md` §3-4 and `../erp-system/obsidian-vault/04-Controllers-Services/AuthController-API.md`.

---

## 2. Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Flutter | SDK ^3.12.2 |
| Language | Dart | ^3.12.2 |
| State Management | Riverpod (planned) | — |
| HTTP Client | Dio (planned) | — |
| Local Storage | SharedPreferences / Hive (planned) | — |
| Routing | Manual (`onGenerateRoute`) | built-in |
| Fonts | Google Fonts (Inter) | ^8.2.0 |
| Icons | Material Icons | built-in |

**Current status**: scaffold phase. Auth UI + home screen are built. Networking, state management, and feature logic are not yet wired.

---

## 3. Architecture — Feature-First + Clean Layering

```
lib/
├── main.dart
├── core/                    # Shared infrastructure
│   ├── constants/           # API URLs, keys, enums
│   ├── network/             # Dio client, interceptors, API base
│   ├── router/              # Route definitions + navigator
│   ├── storage/             # Token storage, secure prefs
│   ├── theme/               # Colors, typography, ThemeData
│   └── widgets/             # Reusable UI (AppButton, AppTextField, etc.)
│
└── features/                # One folder per domain feature
    ├── auth/                # Login, OTP verification, token management
    │   ├── models/          # User, AuthToken DTOs
    │   ├── providers/       # State (Riverpod providers)
    │   ├── repositories/    # API calls (AuthRepository)
    │   ├── screens/         # Full-page widgets
    │   └── widgets/         # Feature-specific UI components
    │
    ├── attendance/          # Clock in/out, scan, GPS
    │   ├── models/
    │   ├── providers/
    │   ├── repositories/
    │   ├── screens/
    │   └── widgets/
    │
    ├── leave/               # Leave requests, balance view
    │   ├── models/
    │   ├── providers/
    │   ├── repositories/
    │   ├── screens/
    │   └── widgets/
    │
    ├── profile/             # Employee profile, settings
    │   ├── models/
    │   ├── providers/
    │   ├── screens/
    │   └── widgets/
    │
    └── home/                # Dashboard, quick actions
        ├── screens/
        └── widgets/
```

### Rules

- **One feature = one folder** with `models/`, `providers/`, `repositories/`, `screens/`, `widgets/`.
- **models/**: plain Dart classes (DTOs). `fromJson` factory + `toJson` method. Immutable (`final` fields).
- **repositories/**: API communication only. One class per feature (`AuthRepository`, `AttendanceRepository`). Returns typed models, never raw `Response`.
- **providers/**: Riverpod providers (or state notifiers). Business logic lives here, not in widgets.
- **screens/**: full-page `StatelessWidget` or `ConsumerWidget`. Compose from `widgets/`.
- **widgets/**: feature-specific UI pieces. Reusable cross-feature widgets go in `core/widgets/`.
- **No business logic in widgets/screens**. Only UI + provider reads.

---

## 4. Conventions

### Dart / Flutter

- **File naming**: `snake_case.dart` always. Classes `PascalCase`.
- **Prefer `const`** constructors everywhere possible.
- **No `dynamic`** — use proper types. Models use `final` fields.
- **Immutable state**: don't mutate — create new instances.
- **Widget decomposition**: if a `build()` method exceeds ~80 lines, extract sub-widgets.
- **Error handling**: never swallow exceptions. Show user-friendly messages via `AppDialog.showError()`.

### Reusable Widgets (always use these)

| Widget | File | Use instead of |
|--------|------|---------------|
| `AppButton` | `core/widgets/app_button.dart` | raw `ElevatedButton`/`OutlinedButton` |
| `AppTextField` | `core/widgets/app_text_field.dart` | raw `TextFormField` |
| `AppDropdown` | `core/widgets/app_dropdown.dart` | raw `DropdownButtonFormField` |
| `AppDialog` | `core/widgets/app_dialog.dart` | raw `showDialog()` |
| `AppLoading` | `core/widgets/app_loading.dart` | raw `CircularProgressIndicator` |
| `AppLoadingOverlay` | `core/widgets/app_loading.dart` | custom loading stacks |

### Navigation

- Routes defined in `core/router/app_routes.dart` (string constants).
- Navigation via `AppRouter.navigateTo()` / `navigateToReplacement()` / `navigateToAndRemoveUntil()`.
- Never use raw `Navigator.push()` — always go through `AppRouter`.

### Theme & Styling

- Use `AppColors.*` from `core/theme/app_theme.dart`. Never hardcode hex colors.
- Use theme-aware text styles (`Theme.of(context).textTheme.*`).
- Consistent spacing: 8 / 12 / 16 / 20 / 24 / 32.

---

## 5. ERP Integration Contract

This app connects to the same ERP backend as the web admin panel.

### Authentication

- **Endpoint**: `POST /api/v1/login` → phone/email + password → OTP sent
- **OTP verify**: `POST /api/v1/verify-otp` → returns Sanctum token
- **Token refresh**: `POST /api/v1/refresh-token` (auth required)
- **Logout**: `POST /api/v1/logout` (auth required)
- Token stored securely in device (FlutterSecureStorage or equivalent).
- **Mobile access gate**: backend checks `users.has_mobile_access` (boolean) at login. If `false`, returns 403 "Mobile access is not enabled for your account." Admin toggles this per user.
- See ERP: `obsidian-vault/04-Controllers-Services/AuthController-API.md`

### Attendance API (planned — to be built on ERP side)

| Action | Method | Endpoint (planned) | Notes |
|--------|--------|-------------------|-------|
| Clock in | POST | `/api/v1/attendance/clock-in` | GPS coords + photo |
| Clock out | POST | `/api/v1/attendance/clock-out` | GPS coords + photo |
| Today's status | GET | `/api/v1/attendance/today` | Current clock state |
| History | GET | `/api/v1/attendance` | Paginated, filterable |
| Monthly summary | GET | `/api/v1/attendance/summary?month=` | Stats |

### Leave API (syncs with ERP Leave Management)

| Action | Method | Endpoint (planned) | Notes |
|--------|--------|-------------------|-------|
| My balances | GET | `/api/v1/leave/balances` | Per leave type |
| Request leave | POST | `/api/v1/leave/requests` | date_from, date_to, type, reason |
| My requests | GET | `/api/v1/leave/requests` | With status |
| Cancel request | POST | `/api/v1/leave/requests/{id}/cancel` | Before approval only |

### Profile API

| Action | Method | Endpoint | Notes |
|--------|--------|----------|-------|
| My profile | GET | `/api/v1/user` | Existing ERP endpoint |

### Important

- All API requests include `Authorization: Bearer {token}` header.
- All responses follow Laravel Resource format: `{ data: {...}, meta?: {...} }`.
- Company scoping is automatic (via token's user → company).
- Error responses: `{ message: "...", errors?: { field: ["..."] } }`.

---

## 6. Planned Features (Roadmap)

| Priority | Feature | Status | ERP Module |
|----------|---------|--------|------------|
| P0 | Auth (login + OTP) | UI done, API not wired | Users & Access |
| P0 | Clock in/out | Not started | Attendance (new) |
| P1 | Leave request | Not started | Leave Management |
| P1 | Leave balance view | Not started | Leave Management |
| P2 | Attendance history | Not started | Attendance (new) |
| P2 | Profile view | Not started | Users & Access |
| P3 | Push notifications | Not started | — |
| P3 | Offline support | Not started | — |

---

## 7. Verification

- **Lint**: `flutter analyze` — zero warnings required.
- **Build**: `flutter build apk --debug` (Android) or `flutter build ios --no-codesign` (iOS).
- **Format**: `dart format .` — enforced.
- **Test**: `flutter test` when tests exist.
- If changing a widget used in multiple places, verify all usages still work.

---

## 8. Dependencies to Add (when features begin)

Add these when actually implementing the features, not before:

```yaml
# State management
flutter_riverpod: ^2.6.0
riverpod_annotation: ^2.6.0

# Networking
dio: ^5.7.0
retrofit: ^4.4.0  # optional, for typed API clients

# Storage
flutter_secure_storage: ^9.2.0
shared_preferences: ^2.3.0

# Location
geolocator: ^13.0.0
geocoding: ^3.0.0

# Camera
camera: ^0.11.0
image_picker: ^1.1.0

# Push notifications
firebase_messaging: ^15.1.0
flutter_local_notifications: ^18.0.0

# Utils
intl: ^0.20.0           # date formatting
connectivity_plus: ^6.1.0  # offline detection
```

---

## 9. Cross-Repo References

| Topic | Location |
|-------|----------|
| ERP API auth flow | `../erp-system/obsidian-vault/04-Controllers-Services/AuthController-API.md` |
| ERP Leave Management | `../erp-system/obsidian-vault/02-Domains/Leave Management.md` |
| ERP User model | `../erp-system/obsidian-vault/02-Domains/Users & Access.md` |
| ERP Conventions | `../erp-system/AGENTS.md` |
| Workspace coordination | `../AGENTS.md` |
