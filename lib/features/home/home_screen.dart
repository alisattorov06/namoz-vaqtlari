import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:namoz_vaqtlari/core/constants/app_colors.dart';
import 'package:namoz_vaqtlari/core/constants/app_strings.dart';
import 'package:namoz_vaqtlari/core/models/prayer_time_model.dart';
import 'package:namoz_vaqtlari/core/providers/prayer_provider.dart';
import 'package:namoz_vaqtlari/features/onboarding/location_picker_sheet.dart';

/// Bosh sahifa - bugungi namoz vaqtlari
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.today == null) {
          return const _LoadingView();
        }
        return RefreshIndicator(
          onRefresh: () => provider.refreshPrayerTimes(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, provider)),
              SliverToBoxAdapter(child: _buildNextPrayerCard(context, provider)),
              SliverToBoxAdapter(child: _buildLocationRow(context, provider)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverToBoxAdapter(
                  child: _buildPrayerList(context, provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PrayerProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.mosque,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Namoz Vaqtlari',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => provider.refreshPrayerTimes(),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _formatGregorian(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatHijri(),
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard(BuildContext context, PrayerProvider provider) {
    final next = provider.nextPrayer;
    if (next == null) return const SizedBox.shrink();
    final timeLeft = provider.timeToNextPrayer ?? Duration.zero;
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Keyingi namoz',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              next.name,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(next.time),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            _buildCountdown(timeLeft),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _timeBox(hours.toString().padLeft(2, '0'), 'soat'),
        const SizedBox(width: 8),
        const Text(':',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        _timeBox(minutes.toString().padLeft(2, '0'), 'daq'),
        const SizedBox(width: 8),
        const Text(':',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        _timeBox(seconds.toString().padLeft(2, '0'), 'son'),
      ],
    );
  }

  Widget _timeBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, PrayerProvider provider) {
    final location = provider.location;
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                location?.isGps == true ? Icons.gps_fixed : Icons.location_city,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location?.cityName ?? 'Joylashuv tanlanmagan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (location?.regionName != null)
                    Text(
                      location!.regionName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showLocationPicker(context),
              icon: const Icon(Icons.edit_location_alt, size: 18),
              label: const Text('O\'zgartirish'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerList(BuildContext context, PrayerProvider provider) {
    final today = provider.today;
    if (today == null) return const SizedBox.shrink();
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 8, bottom: 12),
          child: Text(
            AppStrings.prayers,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        ...today.prayers.map((p) => _buildPrayerCard(context, p, now, provider)),
      ],
    );
  }

  Widget _buildPrayerCard(
      BuildContext context, PrayerTime prayer, DateTime now, PrayerProvider provider) {
    final isPassed = prayer.time.isBefore(now);
    final isNext = !isPassed && prayer.name != 'Quyosh';

    Color textColor = isPassed
        ? AppColors.passed
        : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    Color bgColor = Theme.of(context).cardColor;

    if (isNext) {
      bgColor = AppColors.primary.withOpacity(0.08);
    }

    IconData icon;
    switch (prayer.name) {
      case 'Bomdod':
        icon = Icons.wb_twilight;
        break;
      case 'Quyosh':
        icon = Icons.wb_sunny;
        break;
      case 'Peshin':
        icon = Icons.sunny_snowing;
        break;
      case 'Asr':
        icon = Icons.wb_cloudy;
        break;
      case 'Shom':
        icon = Icons.nights_stay;
        break;
      case 'Xufton':
        icon = Icons.dark_mode;
        break;
      default:
        icon = Icons.access_time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isNext
            ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPassed
                  ? AppColors.passed.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isPassed ? AppColors.passed : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      prayer.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        decoration: isPassed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (isNext) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Yaqin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isPassed)
                  const Text(
                    'O\'tib ketdi',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.passed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(prayer.time),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isPassed
                      ? AppColors.passed
                      : (isNext ? AppColors.primary : textColor),
                ),
              ),
              if (prayer.name != 'Quyosh')
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: prayer.isAlarmEnabled,
                    onChanged: (v) => provider.togglePrayerAlarm(prayer.name, v),
                    activeColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerSheet(
        onSelected: (loc) {
          Navigator.of(context).pop();
          context.read<PrayerProvider>().setLocation(loc);
        },
      ),
    );
  }

  String _formatGregorian() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMMM yyyy', 'uz').format(now);
  }

  String _formatHijri() {
    const months = [
      'Muharram', 'Safar', "Robi'ul-avval", "Robi'ul-oxir",
      'Jumodiyul-avval', 'Jumodiyul-oxir', 'Rajab', "Sha'bon",
      'Ramazon', 'Shavvol', 'Zil-qa\'da', 'Zil-hajja'
    ];
    final today = DateTime.now();
    final julianDay = today.difference(DateTime(622, 7, 16)).inDays;
    final hijriYear = (julianDay / 354.37).floor() + 1;
    final dayOfYear = julianDay - ((hijriYear - 1) * 354);
    final month = (dayOfYear / 29.5).floor() + 1;
    final day = (dayOfYear % 29).toInt() + 1;
    return '$day ${months[(month - 1).clamp(0, 11)]} $hijriYear hijriy';
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mosque, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Namoz vaqtlari yuklanmoqda...',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
