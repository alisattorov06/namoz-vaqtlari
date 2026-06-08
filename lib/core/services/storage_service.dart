import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namoz_vaqtlari/core/models/prayer_time_model.dart';
import 'package:namoz_vaqtlari/core/models/location_model.dart';

/// Mahalliy saqlash xizmati
class StorageService {
  static const _prayerBox = 'prayer_times';

  static const _keyOnboarding = 'onboarding_done';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocation = 'user_location';
  static const _keyHijriOffset = 'hijri_offset';
  static const _keyCalculationMethod = 'calculation_method';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyPreNotification = 'pre_notification_minutes';
  static const _keyAtTimeNotification = 'at_time_notification';
  static const _keyAlarmSound = 'alarm_sound';
  static const _keyTasbehCount = 'tasbeh_count';
  static const _keyTasbehIndex = 'tasbeh_index';
  static const _keyVibrationEnabled = 'vibration_enabled';
  static const _keyTasbehTarget = 'tasbeh_target';
  static const _keyTasbehVibrate = 'tasbeh_vibrate';
  static const _keyTasbehSound = 'tasbeh_sound';

  late SharedPreferences _prefs;
  late Box<String> _prayerCacheBox;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    _prayerCacheBox = await Hive.openBox<String>(_prayerBox);
  }

  // Onboarding
  bool isOnboardingDone() => _prefs.getBool(_keyOnboarding) ?? false;
  Future<void> setOnboardingDone(bool value) async =>
      await _prefs.setBool(_keyOnboarding, value);

  // Theme
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) async =>
      await _prefs.setString(_keyThemeMode, mode);

  // Location
  LocationModel? getLocation() {
    final str = _prefs.getString(_keyLocation);
    if (str == null) return null;
    try {
      return LocationModel.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  Future<void> setLocation(LocationModel location) async {
    await _prefs.setString(_keyLocation, jsonEncode(location.toJson()));
  }

  // Hijri offset
  int getHijriOffset() => _prefs.getInt(_keyHijriOffset) ?? 0;
  Future<void> setHijriOffset(int offset) async =>
      await _prefs.setInt(_keyHijriOffset, offset);

  // Calculation method
  String getCalculationMethod() =>
      _prefs.getString(_keyCalculationMethod) ?? 'MuslimWorldLeague';
  Future<void> setCalculationMethod(String method) async =>
      await _prefs.setString(_keyCalculationMethod, method);

  // Notifications
  bool getNotificationsEnabled() =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) async =>
      await _prefs.setBool(_keyNotificationsEnabled, value);

  int getPreNotificationMinutes() =>
      _prefs.getInt(_keyPreNotification) ?? 5;
  Future<void> setPreNotificationMinutes(int minutes) async =>
      await _prefs.setInt(_keyPreNotification, minutes);

  bool getAtTimeNotification() =>
      _prefs.getBool(_keyAtTimeNotification) ?? true;
  Future<void> setAtTimeNotification(bool value) async =>
      await _prefs.setBool(_keyAtTimeNotification, value);

  // Alarm sound
  String getAlarmSound() => _prefs.getString(_keyAlarmSound) ?? 'default';
  Future<void> setAlarmSound(String sound) async =>
      await _prefs.setString(_keyAlarmSound, sound);

  // Tasbeh
  int getTasbehCount() => _prefs.getInt(_keyTasbehCount) ?? 0;
  Future<void> setTasbehCount(int count) async =>
      await _prefs.setInt(_keyTasbehCount, count);

  int getTasbehIndex() => _prefs.getInt(_keyTasbehIndex) ?? 0;
  Future<void> setTasbehIndex(int index) async =>
      await _prefs.setInt(_keyTasbehIndex, index);

  bool getTasbehVibrate() => _prefs.getBool(_keyTasbehVibrate) ?? true;
  Future<void> setTasbehVibrate(bool value) async =>
      await _prefs.setBool(_keyTasbehVibrate, value);

  bool getTasbehSound() => _prefs.getBool(_keyTasbehSound) ?? false;
  Future<void> setTasbehSound(bool value) async =>
      await _prefs.setBool(_keyTasbehSound, value);

  int getTasbehTarget() => _prefs.getInt(_keyTasbehTarget) ?? 33;
  Future<void> setTasbehTarget(int target) async =>
      await _prefs.setInt(_keyTasbehTarget, target);

  /// Namoz vaqtlarini cache ga saqlash (7 kunlik)
  Future<void> cachePrayerTimes(List<DailyPrayerTimes> times) async {
    await _prayerCacheBox.clear();
    final box = _prayerCacheBox;
    for (var i = 0; i < times.length; i++) {
      await box.put('day_$i', jsonEncode(times[i].toJson()));
    }
  }

  /// Cache dan namoz vaqtlarini olish
  List<DailyPrayerTimes> getCachedPrayerTimes() {
    final result = <DailyPrayerTimes>[];
    final box = _prayerCacheBox;
    for (var i = 0; i < 7; i++) {
      final str = box.get('day_$i');
      if (str != null) {
        try {
          result.add(DailyPrayerTimes.fromJson(jsonDecode(str)));
        } catch (_) {}
      }
    }
    return result;
  }

  /// Bugungi kun uchun cache dan olish
  DailyPrayerTimes? getTodayCachedPrayerTimes() {
    final all = getCachedPrayerTimes();
    if (all.isEmpty) return null;
    final today = DateTime.now();
    for (final d in all) {
      if (d.date.year == today.year &&
          d.date.month == today.month &&
          d.date.day == today.day) {
        return d;
      }
    }
    return all.first;
  }

  /// Cache tozalash
  Future<void> clearCache() async {
    await _prayerCacheBox.clear();
  }
}
