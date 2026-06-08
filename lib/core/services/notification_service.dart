import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:namoz_vaqtlari/core/models/prayer_time_model.dart';

/// Bildirishnomalar va alarm xizmati
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _prayerChannelId = 'prayer_notifications';
  static const String _prayerChannelName = 'Namoz vaqtlari';
  static const String _prayerChannelDesc = 'Namoz vaqtlari haqida eslatmalar';

  static bool _initialized = false;

  /// Xizmatni boshlash
  static Future<void> init() async {
    if (_initialized) return;

    // Timezone ma'lumotlarini yuklash
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));
    }

    // Android sozlamalari
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Bildirishnoma bosildi: ${response.payload}');
      },
    );

    // Android 13+ uchun kanal yaratish
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _prayerChannelId,
        _prayerChannelName,
        description: _prayerChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Ruxsat so'rash
    await _requestNotificationPermission();
    await _requestExactAlarmPermission();
    await _requestBatteryOptimizationPermission();

    _initialized = true;
  }

  /// Bildirishnomalar ruxsatini so'rash
  static Future<bool> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Aniq alarm ruxsatini so'rash
  static Future<bool> _requestExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  /// Batareya optimallashtirish ruxsati
  static Future<bool> _requestBatteryOptimizationPermission() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    return status.isGranted;
  }

  /// Barcha ruxsatlarni qayta so'rash (onboarding uchun)
  static Future<Map<String, bool>> requestAllPermissions() async {
    return {
      'notification': await _requestNotificationPermission(),
      'exactAlarm': await _requestExactAlarmPermission(),
      'battery': await _requestBatteryOptimizationPermission(),
    };
  }

  /// Namoz vaqti uchun bildirishnoma rejalashtirish
  static Future<void> schedulePrayerNotification({
    required PrayerTime prayer,
    required int preMinutes,
    required bool atTimeEnabled,
  }) async {
    await cancelPrayerNotification(prayer.name);

    // Oldindan eslatma
    if (preMinutes > 0) {
      final preTime = prayer.time.subtract(Duration(minutes: preMinutes));
      if (preTime.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: _prayerId(preMinutes, prayer.name),
          title: '${prayer.name} namozi',
          body: '$preMinutes daqiqadan so\'ng ${prayer.name} namoziga. Namozga shoshiling.',
          scheduledTime: preTime,
        );
      }
    }

    // Vaqtida eslatma
    if (atTimeEnabled) {
      if (prayer.time.isAfter(DateTime.now())) {
        await _scheduleAt(
          id: _prayerId(0, prayer.name),
          title: '${prayer.name} namozi vaqti kirdi',
          body: 'Alloh taolo ${prayer.name} namozini o\'qishni nasib etsin.',
          scheduledTime: prayer.time,
        );
      }
    }
  }

  /// ID generatsiya
  static int _prayerId(int offset, String name) {
    final base = name.hashCode;
    return (base + offset).abs() % 2147483647;
  }

  /// Vaqtga rejalashtirish
  static Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _prayerChannelId,
        _prayerChannelName,
        channelDescription: _prayerChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        fullScreenIntent: true,
      ),
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: 'prayer_$id',
      );
    } catch (e) {
      debugPrint('Bildirishnoma rejalashtirishda xatolik: $e');
    }
  }

  /// Bitta namoz uchun bildirishnomani bekor qilish
  static Future<void> cancelPrayerNotification(String prayerName) async {
    for (final offset in [0, 5, 10, 15, 30]) {
      await _notifications.cancel(_prayerId(offset, prayerName));
    }
  }

  /// Barcha bildirishnomalarni bekor qilish
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Barcha namoz vaqtlarini rejalashtirish
  static Future<void> scheduleAll({
    required List<PrayerTime> prayers,
    required int preMinutes,
    required bool atTimeEnabled,
    required bool globalEnabled,
  }) async {
    await cancelAll();
    if (!globalEnabled) return;

    for (final prayer in prayers) {
      if (prayer.isAlarmEnabled && prayer.name != 'Quyosh') {
        await schedulePrayerNotification(
          prayer: prayer,
          preMinutes: preMinutes,
          atTimeEnabled: atTimeEnabled,
        );
      }
    }
  }

  /// Telefon qayta yoqilgandan keyin qayta rejalashtirish
  static Future<void> rescheduleAfterBoot() async {
    // Bu metod ilova qayta ishga tushganda chaqiriladi
    // Saqlangan namoz vaqtlarini qayta yuklab, bildirishnomalarni o'rnatadi
  }

  /// Zudlik bilan test bildirishnoma
  static Future<void> showTestNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _prayerChannelId,
        _prayerChannelName,
        channelDescription: _prayerChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _notifications.show(
      99999,
      'Namoz Vaqtlari',
      'Bildirishnomalar muvaffaqiyatli ishlayapti!',
      details,
    );
  }
}
