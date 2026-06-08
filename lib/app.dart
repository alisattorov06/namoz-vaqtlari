import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/prayer_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/storage_service.dart';
import 'features/onboarding/permission_screen.dart';
import 'shared/widgets/main_scaffold.dart';

class NamozApp extends StatelessWidget {
  const NamozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Namoz Vaqtlari',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          home: Consumer<PrayerProvider>(
            builder: (context, prayer, _) {
              final storage = context.read<StorageService>();
              if (!storage.isOnboardingDone()) {
                return const PermissionScreen();
              }
              return const MainScaffold();
            },
          ),
        );
      },
    );
  }
}
