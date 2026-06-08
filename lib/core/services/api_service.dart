import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_time_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  // Method 3 = Muslim World League (O'zbekiston uchun mos)
  // school=1 = Hanafi (Asr vaqti)
  static const int _method = 3;
  static const int _school = 1;

  /// Bugungi namoz vaqtlarini olish
  static Future<PrayerTime?> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final now = DateTime.now();
      final date = '${now.day.toString().padLeft(2, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.year}';

      final uri = Uri.parse(
        '$_baseUrl/timings/$date'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$_method'
        '&school=$_school',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['code'] == 200) {
          return PrayerTime.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Keyingi 7 kunlik namoz vaqtlarini olish
  static Future<List<PrayerTime>> getWeeklyPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final List<PrayerTime> result = [];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final day = now.add(Duration(days: i));
      final pt = await _getPrayerTimeForDate(
        latitude: latitude,
        longitude: longitude,
        date: day,
      );
      if (pt != null) result.add(pt);
    }

    return result;
  }

  static Future<PrayerTime?> _getPrayerTimeForDate({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year}';

      final uri = Uri.parse(
        '$_baseUrl/timings/$dateStr'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$_method'
        '&school=$_school',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['code'] == 200) {
          return PrayerTime.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Oy bo'yicha barcha vaqtlar (Calendar endpoint)
  static Future<List<PrayerTime>> getMonthlyCalendar({
    required double latitude,
    required double longitude,
    int? year,
    int? month,
  }) async {
    try {
      final now = DateTime.now();
      final y = year ?? now.year;
      final m = month ?? now.month;

      final uri = Uri.parse(
        '$_baseUrl/calendar/$y/$m'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$_method'
        '&school=$_school',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['code'] == 200) {
          final data = body['data'] as List<dynamic>;
          return data
              .map((e) => PrayerTime.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Qibla yo'nalishini olish
  static Future<double?> getQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/qibla/$latitude/$longitude',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['code'] == 200) {
          final data = body['data'] as Map<String, dynamic>;
          return (data['direction'] as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Internet bor-yo'qligini tekshirish
  static Future<bool> checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.aladhan.com/v1/status'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
