import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/prayer_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/qibla_provider.dart';
import 'app.dart';

Future<void> main() async {
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

  // intl locale datalarini yuklash (uzbekcha formatlash uchun)
  await initializeDateFormatting('uz', null);

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
        ChangeNotifierProvider(
          create: (_) => QiblaProvider(),
        ),
      ],
      child: const NamozApp(),
    ),
  );
}
