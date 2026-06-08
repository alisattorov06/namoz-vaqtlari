import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hijri/hijri.dart' as hijri_pkg;
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
    return connectivityResult != ConnectivityResult.none;
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
        '$_baseUrl/timings/${{
          'latitude': latitude,
          'longitude': longitude,
          'method': 3, // Muslim World League
        }.entries.map((e) => '${e.key}=${e.value}').join('&')}',
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
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
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
      final gregorian = date['gregorian'] as Map<String, dynamic>;
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
      final hijriDate = Hijri.now().toFormat("dd MMMM yyyy");

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
    final cleanTime = timeStr.split(' ')[0]; // "(+05:00)" formatini olib tashlash
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
        final url = Uri.parse(
          '$_baseUrl/timings/${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}'
              '?latitude=$latitude&longitude=$longitude&method=3',
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

  /// Hijriy sanani olish (offset bilan)
  String getHijriDate({int offsetDays = 0}) {
    final today = DateTime.now();
    final h = hijri_pkg.Hijri.fromDate(today);
    if (offsetDays != 0) {
      final newDate = today.add(Duration(days: offsetDays));
      return hijri_pkg.Hijri.fromDate(newDate).toFormat("dd MMMM yyyy");
    }
    return h.toFormat("dd MMMM yyyy");
  }
}
