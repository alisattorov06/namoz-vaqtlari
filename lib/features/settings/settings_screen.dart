import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namoz_vaqtlari/core/constants/app_colors.dart';
import 'package:namoz_vaqtlari/core/providers/prayer_provider.dart';
import 'package:namoz_vaqtlari/core/providers/theme_provider.dart';
import 'package:namoz_vaqtlari/core/services/notification_service.dart';
import 'package:namoz_vaqtlari/core/services/storage_service.dart';
import 'package:namoz_vaqtlari/features/about/about_screen.dart';

/// Sozlamalar sahifasi
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F7FB), Color(0xFFE8F2E8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: [
                    _sectionTitle('Mavzu'),
                    Consumer<ThemeProvider>(
                      builder: (_, theme, __) => _themeCard(context, theme),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Bildirishnomalar'),
                    _switchTile(
                      context,
                      icon: Icons.notifications_active,
                      title: 'Bildirishnomalarni yoqish',
                      value: storage.getNotificationsEnabled(),
                      onChanged: (v) async {
                        await storage.setNotificationsEnabled(v);
                        if (v) {
                          await NotificationService.requestAllPermissions();
                        }
                        if (context.mounted) {
                          await context
                              .read<PrayerProvider>()
                              .rescheduleNotifications();
                        }
                      },
                    ),
                    _switchTile(
                      context,
                      icon: Icons.alarm,
                      title: 'Vaqtida eslatma',
                      subtitle: 'Namoz vaqti kirganda bildirishnoma',
                      value: storage.getAtTimeNotification(),
                      onChanged: (v) async {
                        await storage.setAtTimeNotification(v);
                        if (context.mounted) {
                          await context
                              .read<PrayerProvider>()
                              .rescheduleNotifications();
                        }
                      },
                    ),
                    _sliderTile(
                      context,
                      icon: Icons.timer,
                      title: 'Oldindan eslatma',
                      subtitle: 'Namozdan ${storage.getPreNotificationMinutes()} daqiqa oldin',
                      value: storage.getPreNotificationMinutes().toDouble(),
                      max: 30,
                      min: 1,
                      divisions: 29,
                      onChanged: (v) async {
                        await storage.setPreNotificationMinutes(v.toInt());
                        if (context.mounted) {
                          await context
                              .read<PrayerProvider>()
                              .rescheduleNotifications();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Ma\'lumotlar'),
                    _actionTile(
                      context,
                      icon: Icons.refresh,
                      title: 'Ma\'lumotlarni yangilash',
                      onTap: () => context
                          .read<PrayerProvider>()
                          .refreshPrayerTimes(),
                    ),
                    _actionTile(
                      context,
                      icon: Icons.notifications_active,
                      title: 'Test bildirishnoma',
                      onTap: () => NotificationService.showTestNotification(),
                    ),
                    _actionTile(
                      context,
                      icon: Icons.delete_outline,
                      title: 'Cache tozalash',
                      onTap: () async {
                        await storage.clearCache();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cache tozalandi'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Boshqa'),
                    _actionTile(
                      context,
                      icon: Icons.info_outline,
                      title: 'Ilova haqida',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AboutScreen()),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Sozlamalar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 0, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _themeCard(BuildContext context, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _themeOption(theme, 'Yorug\'', ThemeMode.light, Icons.light_mode),
          _themeOption(theme, 'Qorong\'i', ThemeMode.dark, Icons.dark_mode),
          _themeOption(theme, 'Tizim', ThemeMode.system, Icons.phone_android),
        ],
      ),
    );
  }

  Widget _themeOption(
      ThemeProvider theme, String label, ThemeMode mode, IconData icon) {
    final selected = theme.themeMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => theme.setThemeMode(mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? Colors.white : AppColors.primary,
                  size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _sliderTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toInt().toString(),
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
