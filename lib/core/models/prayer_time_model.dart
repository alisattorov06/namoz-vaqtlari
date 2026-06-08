import 'package:hive/hive.dart';

part 'prayer_time_model.g.dart';

@HiveType(typeId: 0)
class PrayerTime {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String fajr;

  @HiveField(2)
  final String sunrise;

  @HiveField(3)
  final String dhuhr;

  @HiveField(4)
  final String asr;

  @HiveField(5)
  final String maghrib;

  @HiveField(6)
  final String isha;

  @HiveField(7)
  final String hijriDay;

  @HiveField(8)
  final String hijriMonth;

  @HiveField(9)
  final String hijriYear;

  @HiveField(10)
  final String hijriMonthAr;

  const PrayerTime({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.hijriMonthAr,
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;
    final gregorian = date['gregorian'] as Map<String, dynamic>;
    final hijriMonthData = hijri['month'] as Map<String, dynamic>;

    // Remove timezone offset e.g. "04:23 (+05)"
    String cleanTime(String t) {
      final idx = t.indexOf(' ');
      return idx > 0 ? t.substring(0, idx) : t;
    }

    return PrayerTime(
      date: gregorian['date'] as String? ?? '',
      fajr: cleanTime(timings['Fajr'] as String? ?? '00:00'),
      sunrise: cleanTime(timings['Sunrise'] as String? ?? '00:00'),
      dhuhr: cleanTime(timings['Dhuhr'] as String? ?? '00:00'),
      asr: cleanTime(timings['Asr'] as String? ?? '00:00'),
      maghrib: cleanTime(timings['Maghrib'] as String? ?? '00:00'),
      isha: cleanTime(timings['Isha'] as String? ?? '00:00'),
      hijriDay: hijri['day'] as String? ?? '',
      hijriMonth: (hijriMonthData['number'] ?? 1).toString(),
      hijriYear: hijri['year'] as String? ?? '',
      hijriMonthAr: hijriMonthData['ar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'hijriDay': hijriDay,
        'hijriMonth': hijriMonth,
        'hijriYear': hijriYear,
        'hijriMonthAr': hijriMonthAr,
      };

  factory PrayerTime.fromStoredJson(Map<String, dynamic> json) {
    return PrayerTime(
      date: json['date'] as String? ?? '',
      fajr: json['fajr'] as String? ?? '00:00',
      sunrise: json['sunrise'] as String? ?? '00:00',
      dhuhr: json['dhuhr'] as String? ?? '00:00',
      asr: json['asr'] as String? ?? '00:00',
      maghrib: json['maghrib'] as String? ?? '00:00',
      isha: json['isha'] as String? ?? '00:00',
      hijriDay: json['hijriDay'] as String? ?? '',
      hijriMonth: json['hijriMonth'] as String? ?? '1',
      hijriYear: json['hijriYear'] as String? ?? '',
      hijriMonthAr: json['hijriMonthAr'] as String? ?? '',
    );
  }

  /// Returns DateTime for the given prayer on this date
  DateTime getDateTime(String time24) {
    final parts = date.split('-'); // dd-MM-yyyy
    if (parts.length != 3) return DateTime.now();
    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? 2024;
    final timeParts = time24.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
    return DateTime(year, month, day, hour, minute);
  }

  /// List of prayer entries: [name, time]
  List<Map<String, String>> get allPrayers => [
        {'name': 'Bomdod', 'key': 'fajr', 'time': fajr},
        {'name': 'Quyosh', 'key': 'sunrise', 'time': sunrise},
        {'name': 'Peshin', 'key': 'dhuhr', 'time': dhuhr},
        {'name': 'Asr', 'key': 'asr', 'time': asr},
        {'name': 'Shom', 'key': 'maghrib', 'time': maghrib},
        {'name': 'Xufton', 'key': 'isha', 'time': isha},
      ];

  String get hijriMonthName {
    final idx = (int.tryParse(hijriMonth) ?? 1) - 1;
    const months = [
      'Muharram', 'Safar', 'Rabiul Avval', 'Rabiul Oxir',
      'Jumadil Avval', 'Jumadil Oxir', 'Rajab', "Sha'bon",
      'Ramazon', 'Shavvol', "Zul-Qa'da", 'Zul-Hijja',
    ];
    if (idx >= 0 && idx < months.length) return months[idx];
    return hijriMonthAr;
  }

  String get hijriDateString => '$hijriDay $hijriMonthName $hijriYear';
}
