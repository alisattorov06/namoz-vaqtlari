import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/prayer_time_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Prayer notification IDs (unique per prayer per day)
  static const int _baseIdAtTime = 1000;   // namoz vaqti kirdi
  static const int _baseIdBefore5 = 2000;  // 5 daqiqa oldin

  static final Map<String, int> _prayerIndex = {
    'fajr': 0,
    'sunrise': 1,
    'dhuhr': 2,
    'asr': 3,
    'maghrib': 4,
    'isha': 5,
  };

  static final Map<String, String> _prayerNames = {
    'fajr': 'Bomdod',
    'sunrise': 'Quyosh',
    'dhuhr': 'Peshin',
    'asr': 'Asr',
    'maghrib': 'Shom',
    'isha': 'Xufton',
  };

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final String timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Android notification channel
    const channel = AndroidNotificationChannel(
      'namoz_channel',
      'Namoz Vaqtlari',
      description: 'Namoz vaqtlari haqida bildirishnomalar',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    // Notification bosilganda action
  }

  /// Barcha namoz bildirishnomalarini rejalashtirish
  static Future<void> schedulePrayerNotifications({
    required PrayerTime prayerTime,
    required Map<String, bool> notifEnabled,
    required Map<String, bool> before5Enabled,
  }) async {
    await init();

    final prayers = {
      'fajr': prayerTime.fajr,
      'sunrise': prayerTime.sunrise,
      'dhuhr': prayerTime.dhuhr,
      'asr': prayerTime.asr,
      'maghrib': prayerTime.maghrib,
      'isha': prayerTime.isha,
    };

    for (final entry in prayers.entries) {
      final key = entry.key;
      final time = entry.value;
      final name = _prayerNames[key] ?? key;
      final idx = _prayerIndex[key] ?? 0;

      final prayerDt = prayerTime.getDateTime(time);
      if (prayerDt.isBefore(DateTime.now())) continue;

      // 1) Namoz vaqti kirdi bildirishnomasini rejalashtirish
      if (notifEnabled[key] ?? true) {
        await _scheduleNotification(
          id: _baseIdAtTime + idx,
          title: '$name namozi vaqti kirdi 🕌',
          body: '$name namozi vaqti kirdi. Alloh taolo namozlaringizni qabul qilsin.',
          scheduledTime: prayerDt,
        );
      }

      // 2) 5 daqiqa oldin bildirishnoma
      if (before5Enabled[key] ?? true) {
        final before5Dt = prayerDt.subtract(const Duration(minutes: 5));
        if (before5Dt.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _baseIdBefore5 + idx,
            title: '$name namoziga 5 daqiqa qoldi ⏰',
            body: '$name namoziga 5 daqiqa qoldi. Namozga shoshiling!',
            scheduledTime: before5Dt,
          );
        }
      }
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'namoz_channel',
            'Namoz Vaqtlari',
            channelDescription: 'Namoz vaqtlari haqida bildirishnomalar',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            category: AndroidNotificationCategory.alarm,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint('Bildirishnoma xatosi: $e');
    }
  }

  /// Barcha bildirishnomalarni bekor qilish
  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Bitta bildirishnomani bekor qilish
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Darhol bildirishnoma yuborish (test uchun)
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      9999,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'namoz_channel',
          'Namoz Vaqtlari',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Ruxsat so'rash
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final plugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await plugin?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }
}
