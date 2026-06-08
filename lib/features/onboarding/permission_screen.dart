import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/prayer_provider.dart';
import '../../shared/widgets/main_scaffold.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final Map<String, bool> _granted = {
    'location': false,
    'notification': false,
    'alarm': false,
  };

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _checkExisting();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkExisting() async {
    final location = await Permission.locationWhenInUse.status;
    final notif = await Permission.notification.status;
    final alarm = await Permission.scheduleExactAlarm.status;
    if (mounted) {
      setState(() {
        _granted['location'] = location.isGranted;
        _granted['notification'] = notif.isGranted;
        _granted['alarm'] = alarm.isGranted;
      });
    }
  }

  Future<void> _requestPermission(String key) async {
    setState(() => _loading = true);
    switch (key) {
      case 'location':
        final s = await Permission.locationWhenInUse.request();
        setState(() => _granted[key] = s.isGranted);
        break;
      case 'notification':
        final s = await Permission.notification.request();
        setState(() => _granted[key] = s.isGranted);
        break;
      case 'alarm':
        final s = await Permission.scheduleExactAlarm.request();
        setState(() => _granted[key] = s.isGranted);
        break;
    }
    setState(() => _loading = false);
  }

  Future<void> _continue() async {
    final provider = context.read<PrayerProvider>();
    await provider.initialize();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.darkHeaderGradient
                : AppColors.headerGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const Spacer(),
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mosque_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Namoz Vaqtlari',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ilovadan to\'liq foydalanish uchun\nquyidagi ruxsatlarni bering',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const Spacer(),
                  // Permission cards
                  _PermissionCard(
                    icon: Icons.location_on_rounded,
                    title: 'Joylashuv',
                    description: 'GPS orqali namoz vaqtlarini aniqlash uchun',
                    isGranted: _granted['location']!,
                    onTap: _granted['location']!
                        ? null
                        : () => _requestPermission('location'),
                  ),
                  const SizedBox(height: 12),
                  _PermissionCard(
                    icon: Icons.notifications_rounded,
                    title: 'Bildirishnomalar',
                    description: 'Namoz vaqtlari haqida eslatmalar olish uchun',
                    isGranted: _granted['notification']!,
                    onTap: _granted['notification']!
                        ? null
                        : () => _requestPermission('notification'),
                  ),
                  const SizedBox(height: 12),
                  _PermissionCard(
                    icon: Icons.alarm_rounded,
                    title: 'Aniq vaqt alarms',
                    description: 'Namoz vaqtida aniq signal berish uchun',
                    isGranted: _granted['alarm']!,
                    onTap: _granted['alarm']!
                        ? null
                        : () => _requestPermission('alarm'),
                  ),
                  const Spacer(),
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Davom etish',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loading ? null : _continue,
                    child: Text(
                      'O\'tkazib yuborish',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback? onTap;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isGranted ? 0.25 : 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted
                ? AppColors.accent.withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isGranted
                    ? AppColors.accent.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isGranted ? AppColors.accent : Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isGranted
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.accent, size: 28, key: ValueKey('yes'))
                  : const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 18, key: ValueKey('no')),
            ),
          ],
        ),
      ),
    );
  }
}
