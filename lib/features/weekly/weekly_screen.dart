import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/models/prayer_time_model.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  String _weekday(String dateStr) {
    // dateStr format: dd-MM-yyyy
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final dt = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    return AppStrings.weekdays[(dt.weekday - 1) % 7];
  }

  String _shortDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final day = parts[0];
    final monthIdx = int.tryParse(parts[1]);
    final month = (monthIdx != null && monthIdx >= 1 && monthIdx <= 12)
        ? AppStrings.months[monthIdx - 1]
        : parts[1];
    return '$day $month';
  }

  bool _isToday(String dateStr) {
    final now = DateTime.now();
    final today =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    return dateStr == today;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekly = provider.weeklyPrayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.weeklySchedule),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.refresh(),
          ),
        ],
      ),
      body: weekly.isEmpty
          ? _buildEmpty(context, provider)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: weekly.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final pt = weekly[i];
                final today = _isToday(pt.date);
                return _WeeklyCard(
                  prayerTime: pt,
                  weekday: _weekday(pt.date),
                  shortDate: _shortDate(pt.date),
                  isToday: today,
                  isDark: isDark,
                );
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, PrayerProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Haftalik jadval mavjud emas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => provider.refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Yuklash'),
          ),
        ],
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  final PrayerTime prayerTime;
  final String weekday;
  final String shortDate;
  final bool isToday;
  final bool isDark;

  const _WeeklyCard({
    required this.prayerTime,
    required this.weekday,
    required this.shortDate,
    required this.isToday,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isToday
            ? (isDark
                ? AppColors.darkHeaderGradient
                : AppColors.headerGradient)
            : null,
        color: isToday
            ? null
            : (isDark ? AppColors.cardDark : AppColors.cardLight),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    weekday,
                    style: TextStyle(
                      color: isToday ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  shortDate,
                  style: TextStyle(
                    color: isToday
                        ? Colors.white.withOpacity(0.8)
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (isToday)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Bugun',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // Prayer grid
            Row(
              children: [
                _PrayerCell(
                    name: 'Bomdod',
                    time: prayerTime.fajr,
                    isToday: isToday,
                    icon: Icons.brightness_3_rounded),
                _PrayerCell(
                    name: 'Quyosh',
                    time: prayerTime.sunrise,
                    isToday: isToday,
                    icon: Icons.wb_twilight_rounded),
                _PrayerCell(
                    name: 'Peshin',
                    time: prayerTime.dhuhr,
                    isToday: isToday,
                    icon: Icons.wb_sunny_rounded),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _PrayerCell(
                    name: 'Asr',
                    time: prayerTime.asr,
                    isToday: isToday,
                    icon: Icons.wb_sunny_outlined),
                _PrayerCell(
                    name: 'Shom',
                    time: prayerTime.maghrib,
                    isToday: isToday,
                    icon: Icons.nights_stay_rounded),
                _PrayerCell(
                    name: 'Xufton',
                    time: prayerTime.isha,
                    isToday: isToday,
                    icon: Icons.dark_mode_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerCell extends StatelessWidget {
  final String name;
  final String time;
  final bool isToday;
  final IconData icon;

  const _PrayerCell({
    required this.name,
    required this.time,
    required this.isToday,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isToday
              ? Colors.white.withOpacity(0.12)
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: isToday
                  ? AppColors.accent
                  : (isDark ? AppColors.primaryLight : AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? Colors.white.withOpacity(0.75)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isToday ? Colors.white : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
