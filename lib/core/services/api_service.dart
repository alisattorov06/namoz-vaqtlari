import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:namoz_vaqtlari/core/models/location_model.dart';
import 'package:namoz_vaqtlari/core/models/prayer_time_model.dart';

/// API xizmati - namoz vaqtlarini olish
class ApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _fallbackUrl = 'https://api.pray.zone/v2';

  /// Internet mavjudmi
  Future<bool> hasInternet() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (_) {
      return true;
    }
  }

  /// Bugungi namoz vaqtlarini olish
  Future<DailyPrayerTimes?> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
    required LocationModel location,
  }) async {
    if (!await hasInternet()) return null;

    try {
      final url = Uri.parse(
        '$_baseUrl/timings/now?latitude=$latitude&longitude=$longitude&method=3',
      );
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseAladhanResponse(data, location);
      }
    } catch (_) {
      try {
        return await _getFromFallback(latitude, longitude, location);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<DailyPrayerTimes?> _getFromFallback(
    double lat,
    double lng,
    LocationModel location,
  ) async {
    final url = Uri.parse(
      '$_fallbackUrl/times/today.json?longitude=$lng&latitude=$lat&elevation=0',
    );
    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parsePrayZoneResponse(data, location);
    }
    return null;
  }

  DailyPrayerTimes? _parseAladhanResponse(
    Map<String, dynamic> data,
    LocationModel location,
  ) {
    try {
      final responseData = data['data'] as Map<String, dynamic>;
      final timings = responseData['timings'] as Map<String, dynamic>;
      final date = responseData['date'] as Map<String, dynamic>;
      final hijri = date['hijri'] as Map<String, dynamic>;
      final month = hijri['month'] as Map<String, dynamic>;
      final today = DateTime.now();
      final hijriDate = '${hijri['day']} ${month['en']} ${hijri['year']}';

      return DailyPrayerTimes(
        date: today,
        hijriDate: hijriDate,
        location: location,
        prayers: [
          PrayerTime(name: 'Bomdod', time: _parseTime(timings['Fajr']?.toString(), today)),
          PrayerTime(
            name: 'Quyosh',
            time: _parseTime(timings['Sunrise']?.toString(), today),
            isAlarmEnabled: false,
          ),
          PrayerTime(name: 'Peshin', time: _parseTime(timings['Dhuhr']?.toString(), today)),
          PrayerTime(name: 'Asr', time: _parseTime(timings['Asr']?.toString(), today)),
          PrayerTime(name: 'Shom', time: _parseTime(timings['Maghrib']?.toString(), today)),
          PrayerTime(name: 'Xufton', time: _parseTime(timings['Isha']?.toString(), today)),
        ],
        source: 'api',
      );
    } catch (_) {
      return null;
    }
  }

  DailyPrayerTimes? _parsePrayZoneResponse(
    Map<String, dynamic> data,
    LocationModel location,
  ) {
    try {
      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) return null;
      final timings = results.first as Map<String, dynamic>;
      final today = DateTime.now();

      return DailyPrayerTimes(
        date: today,
        hijriDate: '${today.day}/${today.month}/${today.year}',
        location: location,
        prayers: [
          PrayerTime(name: 'Bomdod', time: _parseTime(timings['Fajr']?.toString(), today)),
          PrayerTime(
            name: 'Quyosh',
            time: _parseTime(timings['Sunrise']?.toString(), today),
            isAlarmEnabled: false,
          ),
          PrayerTime(name: 'Peshin', time: _parseTime(timings['Dhuhr']?.toString(), today)),
          PrayerTime(name: 'Asr', time: _parseTime(timings['Asr']?.toString(), today)),
          PrayerTime(name: 'Shom', time: _parseTime(timings['Maghrib']?.toString(), today)),
          PrayerTime(name: 'Xufton', time: _parseTime(timings['Isha']?.toString(), today)),
        ],
        source: 'api',
      );
    } catch (_) {
      return null;
    }
  }

  DateTime _parseTime(String? timeStr, DateTime date) {
    if (timeStr == null) return date;
    final cleanTime = timeStr.split(' ').first;
    final parts = cleanTime.split(':');
    if (parts.length < 2) return date;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return date;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

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
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final parsed = _parseAladhanResponse(data, location);
          if (parsed != null) result.add(parsed);
        }
      } catch (_) {
        continue;
      }
    }
    return result;
  }

  String getHijriDate({int offsetDays = 0}) {
    const months = [
      'Muharram',
      'Safar',
      "Robi'ul-avval",
      "Robi'ul-oxir",
      'Jumodiyul-avval',
      'Jumodiyul-oxir',
      'Rajab',
      "Sha'bon",
      'Ramazon',
      'Shavvol',
      "Zil-qa'da",
      'Zil-hajja',
    ];
    final date = DateTime.now().add(Duration(days: offsetDays));
    final julianDay = date.difference(DateTime(622, 7, 16)).inDays;
    final hijriYear = (julianDay / 354.37).floor();
    final dayOfYear = julianDay - (hijriYear * 354);
    final month = (dayOfYear / 29.5).floor() + 1;
    final day = (dayOfYear % 29).toInt() + 1;
    return '$day ${months[month.clamp(1, 12) - 1]} ${hijriYear + 1} hijriy';
  }
}
