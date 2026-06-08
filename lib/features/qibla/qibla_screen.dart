import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/qibla_provider.dart';
import '../../core/providers/prayer_provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final prayer = context.read<PrayerProvider>();
    final qibla = context.read<QiblaProvider>();
    await qibla.initialize(
      prayer.location.latitude,
      prayer.location.longitude,
    );
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qibla = context.watch<QiblaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla yo\'nalishi'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _init(),
          ),
        ],
      ),
      body: qibla.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.darkHeaderGradient
                          : AppColors.headerGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mosque_rounded,
                            color: Colors.white, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Makka al-Mukarrama',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (qibla.qiblaDirection != null)
                                Text(
                                  'Yo\'nalish: ${qibla.qiblaDirection!.toStringAsFixed(1)}°',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (qibla.qiblaDirection != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${qibla.qiblaDirection!.toStringAsFixed(0)}°',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Compass
                  if (!qibla.hasCompass)
                    _buildNoCompass(context)
                  else
                    _buildCompass(qibla, isDark),

                  const SizedBox(height: 32),

                  // Status
                  if (qibla.error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(qibla.error!,
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Hint
                  Text(
                    'Kompasni to\'g\'ri ishlashi uchun telefoningizni\nyuzini oldingizga qaratib ushlab turing',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCompass(QiblaProvider qibla, bool isDark) {
    final heading = qibla.compassHeading ?? 0.0;
    final qiblaDir = qibla.qiblaDirection ?? 0.0;
    final angle = (qiblaDir - heading) * (pi / 180);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  isDark
                      ? AppColors.cardDark
                      : AppColors.cardLight,
                  isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Compass directions
          ..._buildDirectionLabels(),

          // Qibla needle
          Transform.rotate(
            angle: angle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.accent, Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Icon(Icons.mosque_rounded,
                    color: AppColors.accent, size: 28),
                Container(
                  width: 6,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),

          // Center dot
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDirectionLabels() {
    final labels = {'Sh': 0.0, 'J': pi / 2, 'G': pi, 'G\'': -pi / 2};
    final labels2 = {
      'Sh': (const Offset(0, -115)),
      'J': (const Offset(115, 0)),
      'G': (const Offset(0, 115)),
      'G\'': (const Offset(-115, 0)),
    };
    return labels2.entries.map((e) {
      final isNorth = e.key == 'Sh';
      return Positioned(
        left: 140 + e.value.dx - 12,
        top: 140 + e.value.dy - 12,
        child: SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Text(
              e.key,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isNorth
                    ? Colors.red.shade400
                    : AppColors.textSecondaryDark,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNoCompass(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_off_rounded, size: 64, color: Colors.orange),
          SizedBox(height: 12),
          Text(
            'Kompas mavjud emas',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'Qurilmangizda kompas sensori topilmadi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
