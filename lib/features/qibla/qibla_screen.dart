import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namoz_vaqtlari/core/constants/app_colors.dart';
import 'package:namoz_vaqtlari/core/providers/prayer_provider.dart';
import 'package:namoz_vaqtlari/core/providers/qibla_provider.dart';

/// Qibla yo'nalishi sahifasi
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final qibla = context.read<QiblaProvider>();
      final prayer = context.read<PrayerProvider>();
      if (prayer.location != null) {
        qibla.calculateQiblaDirection(prayer.location!);
      }
      qibla.startCompass();
    });
  }

  @override
  void dispose() {
    context.read<QiblaProvider>().stopCompass();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F7FB), Color(0xFFE8F2E8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Consumer<QiblaProvider>(
                  builder: (_, qibla, __) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (qibla.isLoading)
                          const CircularProgressIndicator()
                        else if (!qibla.hasCompass)
                          _noCompassView(context)
                        else
                          _compassView(context, qibla),
                        const SizedBox(height: 32),
                        if (qibla.isFacingQibla)
                          _facingQiblaIndicator(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Qibla',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _compassView(BuildContext context, QiblaProvider qibla) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Tashqi doira
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardDark : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              // Yo'nalish belgilari
              CustomPaint(
                size: const Size(300, 300),
                painter: _CompassPainter(
                  heading: qibla.heading,
                  qiblaDirection: qibla.qiblaDirection,
                  isDark: isDark,
                ),
              ),
              // Qibla strelkasi
              Transform.rotate(
                angle: (qibla.qiblaOffset) * (math.pi / 180),
                child: Container(
                  width: 6,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Markaz nuqta
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${qibla.qiblaDirection.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Qibla yo\'nalishi',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _noCompassView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.compass_calibration, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Kompas mavjud emas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Qibla burchagi: ${context.watch<QiblaProvider>().qiblaDirection.toStringAsFixed(1)}°',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Shimolga qaratib, ko\'rsatilgan burchakda buriling',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _facingQiblaIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Text(
            'Qibla tomon yo\'naldingiz!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final double qiblaDirection;
  final bool isDark;

  _CompassPainter({
    required this.heading,
    required this.qiblaDirection,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Chiziqlar
    final linePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 0; i < 360; i += 30) {
      final angle = (i - heading) * (math.pi / 180);
      final p1 = center +
          Offset(math.cos(angle - math.pi / 2) * (radius - 5),
              math.sin(angle - math.pi / 2) * (radius - 5));
      final p2 = center +
          Offset(math.cos(angle - math.pi / 2) * (radius - 15),
              math.sin(angle - math.pi / 2) * (radius - 15));
      canvas.drawLine(p1, p2, linePaint);
    }

    // Shimol (N)
    final textStyle = TextStyle(
      color: isDark ? Colors.white : Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w800,
    );
    final northPainter = TextPainter(
      text: TextSpan(text: 'N', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final northAngle = (0 - heading) * (math.pi / 180);
    final northPos = center +
        Offset(
          math.cos(northAngle - math.pi / 2) * (radius - 30),
          math.sin(northAngle - math.pi / 2) * (radius - 30),
        );
    northPainter.paint(
      canvas,
      northPos.translate(-northPainter.width / 2, -northPainter.height / 2),
    );

    final southPos = center +
        Offset(
          math.cos(northAngle + math.pi / 2) * (radius - 30),
          math.sin(northAngle + math.pi / 2) * (radius - 30),
        );
    final southPainter = TextPainter(
      text: TextSpan(text: 'S', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    southPainter.paint(
      canvas,
      southPos.translate(-southPainter.width / 2, -southPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.heading != heading || old.qiblaDirection != qiblaDirection;
}
