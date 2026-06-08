import 'package:namoz_vaqtlari/core/models/location_model.dart';

/// Bir namoz vaqti modeli
class PrayerTime {
  final String name; // Bomdod, Quyosh, Peshin, Asr, Shom, Xufton
  final DateTime time;
  final bool isAlarmEnabled;

  PrayerTime({
    required this.name,
    required this.time,
    this.isAlarmEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'time': time.toIso8601String(),
        'isAlarmEnabled': isAlarmEnabled,
      };

  factory PrayerTime.fromJson(Map<String, dynamic> json) => PrayerTime(
        name: json['name'] as String,
        time: DateTime.parse(json['time'] as String),
        isAlarmEnabled: json['isAlarmEnabled'] as bool? ?? true,
      );

  PrayerTime copyWith({
    String? name,
    DateTime? time,
    bool? isAlarmEnabled,
  }) {
    return PrayerTime(
      name: name ?? this.name,
      time: time ?? this.time,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
    );
  }

  /// Vaqt o'tib ketganmi
  bool get isPassed => DateTime.now().isAfter(time);
}

/// Bir kunlik namoz vaqtlari
class DailyPrayerTimes {
  final DateTime date;
  final String hijriDate;
  final LocationModel location;
  final List<PrayerTime> prayers;
  final String source; // 'api', 'cache', 'fallback'

  DailyPrayerTimes({
    required this.date,
    required this.hijriDate,
    required this.location,
    required this.prayers,
    this.source = 'api',
  });

  // Bomdod namozi
  PrayerTime get fajr => prayers.firstWhere((p) => p.name == 'Bomdod');
  PrayerTime get sunrise => prayers.firstWhere((p) => p.name == 'Quyosh');
  PrayerTime get dhuhr => prayers.firstWhere((p) => p.name == 'Peshin');
  PrayerTime get asr => prayers.firstWhere((p) => p.name == 'Asr');
  PrayerTime get maghrib => prayers.firstWhere((p) => p.name == 'Shom');
  PrayerTime get isha => prayers.firstWhere((p) => p.name == 'Xufton');

  /// Hozirgi vaqtdan keyingi namoz
  PrayerTime? getNextPrayer() {
    final now = DateTime.now();
    for (final p in prayers) {
      if (p.time.isAfter(now) && p.name != 'Quyosh') {
        return p;
      }
    }
    return null;
  }

  /// Hozirgi faol namoz (oldingi namoz vaqti o'tgan, keyingisi hali kelmagan)
  PrayerTime? getCurrentPrayer() {
    final now = DateTime.now();
    PrayerTime? previousPrayer;
    for (final p in prayers) {
      if (p.time.isAfter(now)) {
        return previousPrayer;
      }
      previousPrayer = p;
    }
    return null;
  }

  /// Keyingi namozgacha qolgan vaqt
  Duration? getTimeToNextPrayer() {
    final next = getNextPrayer();
    if (next == null) return null;
    return next.time.difference(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'hijriDate': hijriDate,
        'location': location.toJson(),
        'prayers': prayers.map((p) => p.toJson()).toList(),
        'source': source,
      };

  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) =>
      DailyPrayerTimes(
        date: DateTime.parse(json['date'] as String),
        hijriDate: json['hijriDate'] as String,
        location:
            LocationModel.fromJson(json['location'] as Map<String, dynamic>),
        prayers: (json['prayers'] as List)
            .map((e) => PrayerTime.fromJson(e as Map<String, dynamic>))
            .toList(),
        source: json['source'] as String? ?? 'api',
      );
}
