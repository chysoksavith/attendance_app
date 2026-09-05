# Attendance Mobile

Flutter mobile app for employee attendance tracking, leave requests, and self-service HR. Connects to the ERP system backend via REST API.

## Tech Stack

- **Flutter** 3.12+ / Dart 3.12+
- **State Management**: Provider (ChangeNotifier)
- **HTTP**: `package:http`
- **Secure Storage**: `flutter_secure_storage` (Keychain / Keystore)
- **Fonts**: Google Fonts (Inter)
- **Icons**: Material Icons

## Prerequisites

- Flutter SDK ^3.12.2 ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or Xcode (for emulator/simulator)
- The ERP backend running locally (for API calls)

## Setup

```bash
# 1. Clone and enter the project
cd attendance-mobile

# 2. Install dependencies
flutter pub get

# 3. Running the app
# Option A (Recommended for physical devices over USB):
./run.sh    # Automatically sets up adb reverse tcp:8000 tcp:8000 and runs flutter

# Option B (Manual):
adb reverse tcp:8000 tcp:8000   # Forward port 8000 from phone to your PC
flutter run
```

> [!NOTE]
> **Why `adb reverse` is needed:** When testing on a physical Android phone connected via USB, `127.0.0.1` refers to the phone itself. `adb reverse tcp:8000 tcp:8000` tells the Android USB driver to route requests from `127.0.0.1:8000` on the phone back to your computer's Laravel server.


## Running the ERP Backend

The app needs the ERP API running. From the sibling repo:

```bash
cd ../erp-system
composer dev    # starts Laravel server + queue + Vite + logs
```

API is available at `http://localhost:8000/api/v1/`.

## Project Structure

```
lib/
├── main.dart                       # App entry + Provider setup
├── core/                           # Shared infrastructure
│   ├── constants/                  # API URLs, storage keys
│   ├── network/                    # HTTP client, exceptions
│   ├── router/                     # Route definitions + navigator
│   ├── storage/                    # Secure token storage
│   ├── theme/                      # Colors, typography, ThemeData
│   └── widgets/                    # Reusable UI components
│
└── features/                       # Feature-first modules
    ├── auth/                       # Login, OTP, session management
    │   ├── models/                 # UserModel, LoginResponse DTOs
    │   ├── providers/              # AuthProvider (state)
    │   ├── repositories/           # AuthRepository (API calls)
    │   ├── screens/                # Splash, Login, OTP screens
    │   └── widgets/                # LoginForm, OtpInput
    ├── attendance/                 # Clock in/out (planned)
    ├── home/                       # Dashboard, quick actions
    └── leave/                      # Leave requests (planned)
```

## Available Commands

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices

# Run analysis (lint)
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Build iOS (requires macOS + Xcode)
flutter build ios
```

## API Configuration

The app connects to the ERP backend. Base URL is configured in `lib/core/constants/api_constants.dart`:

| Environment | URL | Notes |
|-------------|-----|-------|
| Physical Device (USB) | `http://127.0.0.1:8000` (Default) | Requires `adb reverse tcp:8000 tcp:8000` (or use `./run.sh`) |
| Android Emulator | `http://10.0.2.2:8000` | `--dart-define=API_URL=http://10.0.2.2:8000` |
| iOS Simulator | `http://localhost:8000` | Works directly with default URL |
| Physical Device (WiFi) | `http://<your-lan-ip>:8000` | `--dart-define=API_URL=http://<lan-ip>:8000` |
| Production | `https://your-domain.com` | `--dart-define=API_URL=https://your-domain.com` |

## Troubleshooting: "Cannot connect to server / Connection refused"

If the app shows:
> *"Cannot connect to server at http://127.0.0.1:8000. Make sure the backend server is running and port is forwarded."*

1. **Verify ERP backend is running**:
   Make sure `php artisan serve` is active on port 8000 in `erp-system/`.
2. **Re-run port forwarding**:
   If testing on a physical Android phone via USB, whenever the phone is reconnected:
   ```bash
   adb reverse tcp:8000 tcp:8000
   ```
   Or simply use `./run.sh` to launch the app, which automatically sets up port forwarding.


## Auth Flow

1. User enters email/phone + password
2. Backend validates credentials
3. If OTP enabled → verification code sent to email → user enters 6-digit code
4. If OTP disabled → tokens issued immediately
5. Access + refresh tokens stored securely on device
6. App auto-restores session on relaunch

## Architecture Rules

- **Feature-first**: one folder per domain (`auth/`, `attendance/`, `leave/`)
- **Each feature has**: `models/`, `providers/`, `repositories/`, `screens/`, `widgets/`
- **No business logic in UI**: screens only read state from providers
- **Reusable widgets in `core/widgets/`**: always use `AppButton`, `AppTextField`, etc.
- **Typed models**: no `dynamic`, all API responses mapped to Dart classes

See `AGENTS.md` for the full conventions and integration contract with the ERP system.
