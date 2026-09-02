import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/settings_provider.dart';
import 'features/attendance/providers/attendance_provider.dart';
import 'features/attendance/repositories/attendance_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/leave/providers/leave_provider.dart';
import 'features/leave/repositories/leave_repository.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Core dependencies
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage);
    final authRepository = AuthRepository(client: apiClient);
    final attendanceRepository = AttendanceRepository(client: apiClient);
    final leaveRepository = LeaveRepository(client: apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(tokenStorage: tokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: authRepository,
            tokenStorage: tokenStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(repository: attendanceRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => LeaveProvider(repository: leaveRepository),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Attendance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('km', '')],
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
