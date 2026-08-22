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

# 3. Configure API base URL
#    Edit lib/core/constants/api_constants.dart
#    Default: http://10.0.2.2:8000 (Android emulator → host machine)
#    For iOS simulator: http://localhost:8000
#    For physical device: use your machine's LAN IP

# 4. Run the app
flutter run
```

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

The app connects to the ERP backend. Update the base URL in `lib/core/constants/api_constants.dart`:

| Environment | URL |
|-------------|-----|
| Android Emulator | `http://10.0.2.2:8000` (default) |
| iOS Simulator | `http://localhost:8000` |
| Physical Device (WiFi) | `http://<your-lan-ip>:8000` |
| Production | `https://your-domain.com` |

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
