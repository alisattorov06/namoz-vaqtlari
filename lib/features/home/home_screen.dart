import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/prayer_provider.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_list_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Her soniyada UI yangilansin (countdown uchun)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final days = AppStrings.weekdays;
    final months = AppStrings.months;
    final weekday = days[(dt.weekday - 1) % 7];
    final month = months[dt.month - 1];
    return '$weekday, ${dt.day} $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              snap: true,
              backgroundColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mosque_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        provider.location.cityName.isNotEmpty
                            ? provider.location.cityName
                            : provider.location.regionName,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Offline indicator
                if (provider.state == PrayerLoadState.offline)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Tooltip(
                      message: 'Offline rejim',
                      child: Icon(Icons.wifi_off_rounded,
                          color: Colors.orange.shade400, size: 20),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => provider.refresh(),
                  tooltip: 'Yangilash',
                ),
                const SizedBox(width: 4),
              ],
            ),

            // ── Content ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Text(
                      _formatDate(now),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Hijri date
                    if (provider.todayPrayer != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        provider.todayPrayer!.hijriDateString,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Next prayer card
                    if (provider.state == PrayerLoadState.loading)
                      _buildSkeleton(context)
                    else if (provider.todayPrayer != null)
                      NextPrayerCard(provider: provider)
                    else
                      _buildError(context, provider),

                    const SizedBox(height: 24),

                    // Section title
                    Text(
                      AppStrings.todayPrayers,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Prayer List ───────────────────────────────────────────────
            if (provider.state == PrayerLoadState.loading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildCardSkeleton(context),
                    childCount: 6,
                  ),
                ),
              )
            else if (provider.todayPrayer != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final prayers = provider.todayPrayer!.allPrayers;
                      final prayer = prayers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PrayerListCard(
                          name: prayer['name']!,
                          prayerKey: prayer['key']!,
                          time: prayer['time']!,
                          isPassed: provider.isPassed(prayer['time']!),
                          isNext: provider.getNextPrayer()?['key'] ==
                              prayer['key'],
                        ),
                      );
                    },
                    childCount: provider.todayPrayer!.allPrayers.length,
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildCardSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 68,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildError(BuildContext context, PrayerProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            provider.errorMessage ?? AppStrings.errorNoInternet,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(AppStrings.errorTryAgain),
          ),
        ],
      ),
    );
  }
}
