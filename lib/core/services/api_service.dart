import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:namoz_vaqtlari/core/models/location_model.dart';
import 'package:namoz_vaqtlari/core/models/prayer_time_model.dart';

/// API xizmati - namoz vaqtlarini olish
/// API tayyor bo'lganda _baseUrl ni o'zgartirish kerak
class ApiService {
  // TODO: API manzilini shu yerga kiriting
  // Misol: 'https://api.namozvaqtlari.uz/v1'
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  // Fallback uchun boshqa API
  static const String _fallbackUrl = 'https://api.pray.zone/v2';

  /// Internet mavjudmi
  Future<bool> hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final list = connectivityResult is List
        ? connectivityResult
        : <ConnectivityResult>[connectivityResult as ConnectivityResult];
    return list.any((r) => r != ConnectivityResult.none);
  }

  /// Asosiy API dan bugungi namoz vaqtlarini olish
  Future<DailyPrayerTimes?> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
    required LocationModel location,
  }) async {
    if (!await hasInternet()) {
      return null;
    }

    try {
      // Aladhan API - dunyo bo'ylab namoz vaqtlari uchun mashhur
      final url = Uri.parse(
        '$_baseUrl/timings/now?latitude=$latitude&longitude=$longitude&method=3',
      );

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseAladhanResponse(data, location);
      }
    } catch (e) {
      // Fallback ga o'tish
      try {
        return await _getFromFallback(latitude, longitude, location);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Fallback API
  Future<DailyPrayerTimes?> _getFromFallback(
    double lat,
    double lng,
    LocationModel location,
  ) async {
    try {
      final url = Uri.parse(
        '$_fallbackUrl/times/today.json?longitude=$lng&latitude=$lat&elevation=0',
      );
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parsePrayZoneResponse(data, location);
      }
    } catch (_) {}
    return null;
  }

  /// Aladhan API javobini tahlil qilish
  DailyPrayerTimes? _parseAladhanResponse(
      Map<String, dynamic> data, LocationModel location) {
    try {
      final timings = data['data']['timings'] as Map<String, dynamic>;
      final date = data['data']['date'] as Map<String, dynamic>;
      final hijri = date['hijri'] as Map<String, dynamic>;

      final today = DateTime.now();
      final hijriDate = '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}';

      final prayers = [
        PrayerTime(
          name: 'Bomdod',
          time: _parseTime(timings['Fajr'], today),
        ),
        PrayerTime(
          name: 'Quyosh',
          time: _parseTime(timings['Sunrise'], today),
          isAlarmEnabled: false,
        ),
        PrayerTime(
          name: 'Peshin',
          time: _parseTime(timings['Dhuhr'], today),
        ),
        PrayerTime(
          name: 'Asr',
          time: _parseTime(timings['Asr'], today),
        ),
        PrayerTime(
          name: 'Shom',
          time: _parseTime(timings['Maghrib'], today),
        ),
        PrayerTime(
          name: 'Xufton',
          time: _parseTime(timings['Isha'], today),
        ),
      ];

      return DailyPrayerTimes(
        date: today,
        hijriDate: hijriDate,
        location: location,
        prayers: prayers,
        source: 'api',
      );
    } catch (_) {
      return null;
    }
  }

  /// Pray.zone javobini tahlil qilish
  DailyPrayerTimes? _parsePrayZoneResponse(
      Map<String, dynamic> data, LocationModel location) {
    try {
      final results = data['results'] as List;
      if (results.isEmpty) return null;
      final timings = results[0] as Map<String, dynamic>;

      final today = DateTime.now();
      final hijriDate = '${today.day}/${today.month}/${today.year}';

      final prayers = [
        PrayerTime(
          name: 'Bomdod',
          time: _parseTime(timings['Fajr'], today),
        ),
        PrayerTime(
          name: 'Quyosh',
          time: _parseTime(timings['Sunrise'], today),
          isAlarmEnabled: false,
        ),
        PrayerTime(
          name: 'Peshin',
          time: _parseTime(timings['Dhuhr'], today),
        ),
        PrayerTime(
          name: 'Asr',
          time: _parseTime(timings['Asr'], today),
        ),
        PrayerTime(
          name: 'Shom',
          time: _parseTime(timings['Maghrib'], today),
        ),
        PrayerTime(
          name: 'Xufton',
          time: _parseTime(timings['Isha'], today),
        ),
      ];

      return DailyPrayerTimes(
        date: today,
        hijriDate: hijriDate,
        location: location,
        prayers: prayers,
        source: 'api',
      );
    } catch (_) {
      return null;
    }
  }

  /// Vaqtni parse qilish
  DateTime _parseTime(String? timeStr, DateTime date) {
    if (timeStr == null) return date;
    final cleanTime = timeStr.split(' ')[0];
    final parts = cleanTime.split(':');
    if (parts.length < 2) return date;
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Keyingi 7 kun uchun namoz vaqtlarini olish
  Future<List<DailyPrayerTimes>> getWeeklyPrayerTimes({
    required double latitude,
    required double longitude,
    required LocationModel location,
  }) async {
    final result = <DailyPrayerTimes>[];

    for (var i = 0; i < 7; i++) {
      final date = DateTime.now().add(Duration(days: i));
      try {
        final dateStr =
            '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
        final url = Uri.parse(
          '$_baseUrl/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=3',
        );
        final response = await http
            .get(url, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final parsed = _parseAladhanResponse(data, location);
          if (parsed != null) {
            result.add(parsed);
          }
        }
      } catch (_) {
        continue;
      }
    }

    return result;
  }

  /// Hijriy sanani olish
  String getHijriDate({int offsetDays = 0}) {
    final months = [
      'Muharram', 'Safar', "Robi'ul-avval", "Robi'ul-oxir",
      'Jumodiyul-avval', 'Jumodiyul-oxir', 'Rajab', "Sha'bon",
      'Ramazon', 'Shavvol', 'Zil-qa\'da', 'Zil-hajja'
    ];
    final today = DateTime.now();
    final date = today.add(Duration(days: offsetDays));
    // Taxminiy hijri hisoblash (hijri paketi bo'lmasa)
    final julianDay = date.difference(DateTime(622, 7, 16)).inDays;
    final hijriYear = (julianDay / 354.37).floor();
    final dayOfYear = julianDay - (hijriYear * 354);
    final month = (dayOfYear / 29.5).floor() + 1;
    final day = (dayOfYear % 29).toInt() + 1;
    return '$day ${months[month.clamp(1, 12) - 1]} ${hijriYear + 1} hijriy';
  }
}
