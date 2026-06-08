import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/prayer_provider.dart';
import 'core/providers/theme_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final storage = StorageService();
  await storage.init();

  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(
          create: (ctx) => ThemeProvider(ctx.read<StorageService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PrayerProvider(ctx.read<StorageService>()),
        ),
      ],
      child: const NamozApp(),
    ),
  );
}
