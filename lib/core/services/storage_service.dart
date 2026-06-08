import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time_model.dart';
import '../models/location_model.dart';

class StorageService {
  static const String _prayerBox = 'prayer_times';
  static const String _keyLocation = 'saved_location';
  static const String _keyTheme = 'theme_mode';
  static const String _keyOnboarded = 'onboarding_done';
  static const String _keyWeeklyCache = 'weekly_cache';
  static const String _keyWeeklyCacheTime = 'weekly_cache_time';
  static const String _keyTasbehCount = 'tasbeh_count';

  late SharedPreferences _prefs;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PrayerTimeAdapter());
    }
    _box = await Hive.openBox(_prayerBox);
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Prayer Times Cache ───────────────────────────────────────────────────

  Future<void> saveTodayPrayer(PrayerTime pt) async {
    await _prefs.setString('today_prayer', jsonEncode(pt.toJson()));
    await _prefs.setString('today_prayer_date', pt.date);
  }

  PrayerTime? getTodayPrayer() {
    final json = _prefs.getString('today_prayer');
    if (json == null) return null;
    try {
      return PrayerTime.fromStoredJson(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveWeeklyPrayers(List<PrayerTime> prayers) async {
    final encoded = jsonEncode(prayers.map((p) => p.toJson()).toList());
    await _prefs.setString(_keyWeeklyCache, encoded);
    await _prefs.setInt(
        _keyWeeklyCacheTime, DateTime.now().millisecondsSinceEpoch);
  }

  List<PrayerTime> getWeeklyPrayers() {
    final json = _prefs.getString(_keyWeeklyCache);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) =>
              PrayerTime.fromStoredJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  bool isWeeklyCacheValid() {
    final savedTime = _prefs.getInt(_keyWeeklyCacheTime);
    if (savedTime == null) return false;
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(savedTime));
    return diff.inHours < 24;
  }

  // ─── Location ──────────────────────────────────────────────────────────────

  Future<void> saveLocation(LocationModel location) async {
    await _prefs.setString(_keyLocation, jsonEncode(location.toJson()));
  }

  LocationModel? getSavedLocation() {
    final json = _prefs.getString(_keyLocation);
    if (json == null) return null;
    try {
      return LocationModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ─── Settings ──────────────────────────────────────────────────────────────

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyTheme, mode);
  }

  String getThemeMode() => _prefs.getString(_keyTheme) ?? 'system';

  Future<void> setOnboardingDone(bool done) async {
    await _prefs.setBool(_keyOnboarded, done);
  }

  bool isOnboardingDone() => _prefs.getBool(_keyOnboarded) ?? false;

  // ─── Notification Settings ────────────────────────────────────────────────

  Future<void> setNotificationEnabled(String prayerKey, bool enabled) async {
    await _prefs.setBool('notif_$prayerKey', enabled);
  }

  bool isNotificationEnabled(String prayerKey) {
    return _prefs.getBool('notif_$prayerKey') ?? true;
  }

  Future<void> setAlarmEnabled(String prayerKey, bool enabled) async {
    await _prefs.setBool('alarm_$prayerKey', enabled);
  }

  bool isAlarmEnabled(String prayerKey) {
    return _prefs.getBool('alarm_$prayerKey') ?? false;
  }

  Future<void> setNotifBefore5Enabled(String prayerKey, bool enabled) async {
    await _prefs.setBool('notif_before5_$prayerKey', enabled);
  }

  bool isNotifBefore5Enabled(String prayerKey) {
    return _prefs.getBool('notif_before5_$prayerKey') ?? true;
  }

  // ─── Tasbeh ───────────────────────────────────────────────────────────────

  int getTasbehCount() => _prefs.getInt(_keyTasbehCount) ?? 0;

  Future<void> saveTasbehCount(int count) async {
    await _prefs.setInt(_keyTasbehCount, count);
  }

  // ─── Qibla cache ──────────────────────────────────────────────────────────

  Future<void> saveQiblaDirection(double direction) async {
    await _prefs.setDouble('qibla_direction', direction);
  }

  double? getQiblaDirection() => _prefs.getDouble('qibla_direction');

  // ─── Alarm sound ─────────────────────────────────────────────────────────

  Future<void> setAlarmSound(String sound) async {
    await _prefs.setString('alarm_sound', sound);
  }

  String getAlarmSound() => _prefs.getString('alarm_sound') ?? 'default';
}
