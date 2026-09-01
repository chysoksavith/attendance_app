# AGENTS.md — Attendance Mobile App

Single source of truth for all AI agents working on `attendance-mobile/`. Do not fork — edit this file only.

---

## 0. Operating Principles

- **Read before write**: inspect the actual file/widget before changing it.
- **Root-cause over patching**: fail twice → stop, diagnose, propose a different approach.
- **Scope discipline**: solve only what was asked. No bundled refactors.
- **Verify before done**: `flutter analyze` (zero warnings) and `flutter test`.
- **Cross-Repo Rules**: see `../AGENTS.md` and backend API contracts in `../erp-system/obsidian-vault/`.

---

## 1. Project Overview & Tech Stack

- **Purpose**: Employee mobile app for GPS/photo clock-in/out, leave requests, attendance history, and profile management.
- **Stack**: Flutter ^3.12.2 (Dart ^3.12.2), Provider ^6.1.2, `package:http` wrapper, `FlutterSecureStorage` (TokenStorage).
- **Backend API**: Connects to ERP `/api/v1/` using Bearer Sanctum tokens. Scoping is automatic (no manual `company_id`).

---

## 2. Mandatory Architectural Invariants

1. **Feature-First Clean Layering**:
   - Every domain in `lib/features/<feature>/` has: `models/` (immutable DTOs), `repositories/` (API requests), `providers/` (state & logic), `screens/` (page widgets), `widgets/` (sub-components).
   - Zero business logic inside UI widgets/screens.
   - *Reference Skill*: `flutter-feature-scaffold`.

2. **Reusable UI Primitives (Strict)**:
   - Always use `lib/core/widgets/`: `AppButton`, `AppTextField`, `AppDropdown`, `AppDialog`, `AppLoading`.
   - Never use raw unstyled buttons/dialogs.
   - *Reference Skill*: `flutter-feature-scaffold`.

3. **Navigation & Theming**:
   - Navigation via `AppRouter` (`core/router/app_routes.dart`). Never call raw `Navigator.push()`.
   - Colors via `AppColors.*` (`core/theme/app_theme.dart`). Never hardcode raw hex values.
   - Typography via `Theme.of(context).textTheme.*`.

4. **Async State & Error Handling**:
   - Handle loading, error, and data states explicitly in providers. Show user-friendly errors via `AppDialog.showError()`.

---

## 3. ERP Integration Contracts

- **Auth**: `POST /api/v1/login` → `POST /api/v1/verify-otp` (Sanctum token) → `POST /api/v1/logout`.
- **Attendance**: `POST /api/v1/attendance/clock-in`, `POST /api/v1/attendance/clock-out`, `GET /api/v1/attendance/today`, `GET /api/v1/attendance`.
- **Leave**: `GET /api/v1/leave/balances`, `POST /api/v1/leave/requests`, `GET /api/v1/leave/requests`.
- **Profile**: `GET /api/v1/user`.
- *Reference Skill*: `api-contract-sync`.

---

## 4. Verification

- **Lint**: `flutter analyze` — zero warnings required.
- **Format**: `dart format .` — enforced.
- **Test**: `flutter test` — unit and widget tests (*Reference Skill*: `automated-test-authoring`).
