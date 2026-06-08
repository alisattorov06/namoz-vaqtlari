import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../models/location_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';

enum PrayerLoadState { initial, loading, loaded, error, offline }

class PrayerProvider extends ChangeNotifier {
  final StorageService _storage;

  PrayerLoadState _state = PrayerLoadState.initial;
  PrayerTime? _todayPrayer;
  List<PrayerTime> _weeklyPrayers = [];
  LocationModel _location = LocationModel.tashkent;
  String? _errorMessage;
  bool _isOnline = false;

  // Notification & alarm settings
  final Map<String, bool> _notifEnabled = {
    'fajr': true, 'sunrise': false, 'dhuhr': true,
    'asr': true, 'maghrib': true, 'isha': true,
  };
  final Map<String, bool> _before5Enabled = {
    'fajr': true, 'sunrise': false, 'dhuhr': true,
    'asr': true, 'maghrib': true, 'isha': true,
  };
  final Map<String, bool> _alarmEnabled = {
    'fajr': false, 'sunrise': false, 'dhuhr': false,
    'asr': false, 'maghrib': false, 'isha': false,
  };

  PrayerProvider(this._storage) {
    _loadSettings();
  }

  // Getters
  PrayerLoadState get state => _state;
  PrayerTime? get todayPrayer => _todayPrayer;
  List<PrayerTime> get weeklyPrayers => _weeklyPrayers;
  LocationModel get location => _location;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  Map<String, bool> get notifEnabled => Map.unmodifiable(_notifEnabled);
  Map<String, bool> get before5Enabled => Map.unmodifiable(_before5Enabled);
  Map<String, bool> get alarmEnabled => Map.unmodifiable(_alarmEnabled);

  void _loadSettings() {
    final keys = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];
    for (final k in keys) {
      _notifEnabled[k] = _storage.isNotificationEnabled(k);
      _before5Enabled[k] = _storage.isNotifBefore5Enabled(k);
      _alarmEnabled[k] = _storage.isAlarmEnabled(k);
    }
  }

  /// Ilovani birinchi yuklash
  Future<void> initialize() async {
    _state = PrayerLoadState.loading;
    notifyListeners();

    // Saqlangan joylashuvni yuklash
    final savedLocation = _storage.getSavedLocation();
    if (savedLocation != null) _location = savedLocation;

    // Cache dan yuklash
    final cached = _storage.getTodayPrayer();
    if (cached != null) {
      _todayPrayer = cached;
      _state = PrayerLoadState.offline;
    }

    final cachedWeekly = _storage.getWeeklyPrayers();
    if (cachedWeekly.isNotEmpty) _weeklyPrayers = cachedWeekly;

    notifyListeners();

    // Onlinedan yangilash
    await refresh();
  }

  /// Ma'lumotlarni yangilash
  Future<void> refresh() async {
    try {
      _isOnline = await ApiService.checkConnectivity();

      if (_isOnline) {
        await _fetchFromApi();
      } else {
        if (_todayPrayer == null) {
          _state = PrayerLoadState.error;
          _errorMessage = 'Internet aloqasi yo\'q va saqlangan ma\'lumot ham topilmadi';
        } else {
          _state = PrayerLoadState.offline;
        }
      }
    } catch (e) {
      _state = PrayerLoadState.error;
      _errorMessage = 'Yuklashda xatolik: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> _fetchFromApi() async {
    // Bugungi vaqtlar
    final today = await ApiService.getTodayPrayerTimes(
      latitude: _location.latitude,
      longitude: _location.longitude,
    );

    if (today != null) {
      _todayPrayer = today;
      _state = PrayerLoadState.loaded;
      await _storage.saveTodayPrayer(today);
      await _scheduleNotifications(today);
    } else {
      _state = _todayPrayer != null ? PrayerLoadState.offline : PrayerLoadState.error;
    }

    // Haftalik vaqtlar
    if (!_storage.isWeeklyCacheValid()) {
      final weekly = await ApiService.getWeeklyPrayerTimes(
        latitude: _location.latitude,
        longitude: _location.longitude,
      );
      if (weekly.isNotEmpty) {
        _weeklyPrayers = weekly;
        await _storage.saveWeeklyPrayers(weekly);
      }
    }
  }

  /// Joylashuvni yangilash
  Future<void> updateLocation(LocationModel location) async {
    _location = location;
    await _storage.saveLocation(location);
    await refresh();
    notifyListeners();
  }

  /// GPS orqali joylashuvni aniqlash
  Future<bool> useGpsLocation() async {
    _state = PrayerLoadState.loading;
    notifyListeners();

    final loc = await LocationService.getCurrentLocation();
    if (loc != null) {
      await updateLocation(loc);
      return true;
    }
    _state = PrayerLoadState.error;
    _errorMessage = 'GPS joylashuvni aniqlay olmadi';
    notifyListeners();
    return false;
  }

  /// Bildirishnoma sozlamasini o'zgartirish
  Future<void> setNotifEnabled(String key, bool value) async {
    _notifEnabled[key] = value;
    await _storage.setNotificationEnabled(key, value);
    if (_todayPrayer != null) await _scheduleNotifications(_todayPrayer!);
    notifyListeners();
  }

  Future<void> setBefore5Enabled(String key, bool value) async {
    _before5Enabled[key] = value;
    await _storage.setNotifBefore5Enabled(key, value);
    if (_todayPrayer != null) await _scheduleNotifications(_todayPrayer!);
    notifyListeners();
  }

  Future<void> setAlarmEnabled(String key, bool value) async {
    _alarmEnabled[key] = value;
    await _storage.setAlarmEnabled(key, value);
    notifyListeners();
  }

  Future<void> _scheduleNotifications(PrayerTime prayer) async {
    await NotificationService.cancelAllNotifications();
    await NotificationService.schedulePrayerNotifications(
      prayerTime: prayer,
      notifEnabled: _notifEnabled,
      before5Enabled: _before5Enabled,
    );
  }

  /// Keyingi namozni aniqlash
  Map<String, dynamic>? getNextPrayer() {
    if (_todayPrayer == null) return null;
    final now = DateTime.now();
    final prayers = _todayPrayer!.allPrayers;

    for (final p in prayers) {
      final dt = _todayPrayer!.getDateTime(p['time']!);
      if (dt.isAfter(now)) {
        final diff = dt.difference(now);
        return {
          'name': p['name'],
          'key': p['key'],
          'time': p['time'],
          'dateTime': dt,
          'remaining': diff,
        };
      }
    }
    return null;
  }

  /// Namoz o'tib ketganmi?
  bool isPassed(String time) {
    if (_todayPrayer == null) return false;
    final dt = _todayPrayer!.getDateTime(time);
    return dt.isBefore(DateTime.now());
  }
}
