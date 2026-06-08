import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:namoz_vaqtlari/core/models/location_model.dart';
import 'package:namoz_vaqtlari/core/models/prayer_time_model.dart';
import 'package:namoz_vaqtlari/core/services/api_service.dart';
import 'package:namoz_vaqtlari/core/services/notification_service.dart';
import 'package:namoz_vaqtlari/core/services/storage_service.dart';

/// Namoz vaqtlari holati boshqaruvchisi
class PrayerProvider extends ChangeNotifier {
  final StorageService _storage;
  final ApiService _api = ApiService();

  DailyPrayerTimes? _today;
  List<DailyPrayerTimes> _weekly = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _clockTimer;

  PrayerProvider(this._storage) {
    _initialize();
    // Har soniyada vaqtni yangilash
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  DailyPrayerTimes? get today => _today;
  List<DailyPrayerTimes> get weekly => _weekly;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  LocationModel? get location => _storage.getLocation();

  /// Bugungi namoz
  PrayerTime? get nextPrayer => _today?.getNextPrayer();
  PrayerTime? get currentPrayer => _today?.getCurrentPrayer();
  Duration? get timeToNextPrayer => _today?.getTimeToNextPrayer();

  Future<void> _initialize() async {
    // Avval cache dan o'rnatish
    final cached = _storage.getTodayCachedPrayerTimes();
    if (cached != null) {
      _today = cached;
      notifyListeners();
    }
    _weekly = _storage.getCachedPrayerTimes();

    // Joylashuv bo'lsa, API dan yangilash
    final loc = _storage.getLocation();
    if (loc != null) {
      await refreshPrayerTimes(location: loc);
    }
  }

  /// Joylashuvni o'rnatish va ma'lumotlarni yangilash
  Future<void> setLocation(LocationModel location) async {
    await _storage.setLocation(location);
    await refreshPrayerTimes(location: location);
  }

  /// Namoz vaqtlarini yangilash
  Future<void> refreshPrayerTimes({LocationModel? location}) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final loc = location ?? _storage.getLocation();
    if (loc == null) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Joylashuv tanlanmagan';
      notifyListeners();
      return;
    }

    try {
      // Bugungi namoz
      final todayData = await _api.getTodayPrayerTimes(
        latitude: loc.latitude,
        longitude: loc.longitude,
        location: loc,
      );

      if (todayData != null) {
        _today = todayData;
        _hasError = false;
      } else {
        // Cache dan olish
        final cached = _storage.getTodayCachedPrayerTimes();
        if (cached != null) {
          _today = cached;
        } else {
          // Fallback - hisoblangan taxminiy vaqtlar
          _today = _generateFallback(loc);
        }
        _hasError = !await _api.hasInternet();
      }

      // 7 kunlik
      final weekly = await _api.getWeeklyPrayerTimes(
        latitude: loc.latitude,
        longitude: loc.longitude,
        location: loc,
      );
      if (weekly.isNotEmpty) {
        _weekly = weekly;
        await _storage.cachePrayerTimes(weekly);
      } else {
        _weekly = _storage.getCachedPrayerTimes();
      }

      // Bildirishnomalarni rejalashtirish
      await _scheduleNotifications();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bildirishnomalarni rejalashtirish
  Future<void> _scheduleNotifications() async {
    if (_today == null) return;
    final enabled = _storage.getNotificationsEnabled();
    final preMinutes = _storage.getPreNotificationMinutes();
    final atTime = _storage.getAtTimeNotification();
    await NotificationService.scheduleAll(
      prayers: _today!.prayers,
      preMinutes: preMinutes,
      atTimeEnabled: atTime,
      globalEnabled: enabled,
    );
  }

  /// Sozlamalardan keyin bildirishnomalarni qayta rejalashtirish
  Future<void> rescheduleNotifications() async {
    await _scheduleNotifications();
  }

  /// Bitta namoz uchun alarm yoqish/o'chirish
  Future<void> togglePrayerAlarm(String prayerName, bool enabled) async {
    if (_today == null) return;
    final updated = _today!.prayers.map((p) {
      if (p.name == prayerName) {
        return p.copyWith(isAlarmEnabled: enabled);
      }
      return p;
    }).toList();
    _today = DailyPrayerTimes(
      date: _today!.date,
      hijriDate: _today!.hijriDate,
      location: _today!.location,
      prayers: updated,
      source: _today!.source,
    );
    notifyListeners();
    await _scheduleNotifications();
  }

  /// Fallback - taxminiy hisoblangan namoz vaqtlari
  DailyPrayerTimes _generateFallback(LocationModel location) {
    final now = DateTime.now();
    final h = _api.getHijriDate();

    // Taxminiy vaqtlar (joylashuv kengligiga qarab)
    final lat = location.latitude;
    double adjustment = (lat - 41.0) * 0.5; // Taxminiy

    final fajr = DateTime(now.year, now.month, now.day, 4, 30).add(
        Duration(minutes: adjustment.round()));
    final sunrise = fajr.add(const Duration(minutes: 80));
    final dhuhr = DateTime(now.year, now.month, now.day, 12, 30);
    final asr = dhuhr.add(const Duration(hours: 3, minutes: 30));
    final maghrib = dhuhr.add(const Duration(hours: 4, minutes: 30));
    final isha = maghrib.add(const Duration(hours: 1, minutes: 30));

    return DailyPrayerTimes(
      date: now,
      hijriDate: h,
      location: location,
      prayers: [
        PrayerTime(name: 'Bomdod', time: fajr),
        PrayerTime(name: 'Quyosh', time: sunrise, isAlarmEnabled: false),
        PrayerTime(name: 'Peshin', time: dhuhr),
        PrayerTime(name: 'Asr', time: asr),
        PrayerTime(name: 'Shom', time: maghrib),
        PrayerTime(name: 'Xufton', time: isha),
      ],
      source: 'fallback',
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
