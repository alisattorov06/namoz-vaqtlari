import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PrayerListCard extends StatelessWidget {
  final String name;
  final String prayerKey;
  final String time;
  final bool isPassed;
  final bool isNext;

  const PrayerListCard({
    super.key,
    required this.name,
    required this.prayerKey,
    required this.time,
    required this.isPassed,
    required this.isNext,
  });

  IconData get _icon {
    switch (prayerKey) {
      case 'fajr':
        return Icons.brightness_3_rounded;
      case 'sunrise':
        return Icons.wb_twilight_rounded;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.nights_stay_rounded;
      case 'isha':
        return Icons.dark_mode_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  Color _iconColor(bool isDark) {
    if (isPassed) return AppColors.passed;
    if (isNext) return AppColors.accent;
    return isDark ? AppColors.primaryLight : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? (isDark
                ? AppColors.primaryDark.withOpacity(0.4)
                : AppColors.primary.withOpacity(0.08))
            : bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
              ? AppColors.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          // Icon container
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPassed
                  ? (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1))
                  : isNext
                      ? AppColors.accent.withOpacity(0.15)
                      : (isDark
                          ? AppColors.primaryLight.withOpacity(0.12)
                          : AppColors.primary.withOpacity(0.1)),
            ),
            child: Icon(
              _icon,
              color: _iconColor(isDark),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Prayer name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isPassed
                        ? AppColors.passed
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight),
                  ),
                ),
                if (isPassed)
                  Text(
                    'O\'tib ketdi',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.passed.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (isNext)
                  Text(
                    'Keyingi namoz',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // Time
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isPassed
                  ? AppColors.passed
                  : isNext
                      ? AppColors.accent
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
              letterSpacing: 0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          // Passed checkmark
          if (isPassed) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_rounded, color: AppColors.passed.withOpacity(0.6), size: 18),
          ] else if (isNext) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
