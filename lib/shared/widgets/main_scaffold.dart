import 'package:flutter/material.dart';
import 'package:namoz_vaqtlari/core/constants/app_colors.dart';
import 'package:namoz_vaqtlari/core/constants/app_strings.dart';
import 'package:namoz_vaqtlari/features/home/home_screen.dart';
import 'package:namoz_vaqtlari/features/weekly/weekly_screen.dart';
import 'package:namoz_vaqtlari/features/qibla/qibla_screen.dart';
import 'package:namoz_vaqtlari/features/tasbeh/tasbeh_screen.dart';
import 'package:namoz_vaqtlari/features/settings/settings_screen.dart';

/// Asosiy sahifa - BottomNavigation bilan
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    WeeklyScreen(),
    QiblaScreen(),
    TasbehScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.wb_twilight, AppStrings.navHome),
                _buildNavItem(1, Icons.calendar_view_week,
                    AppStrings.navWeekly),
                _buildNavItem(2, Icons.explore, AppStrings.navQibla),
                _buildNavItem(3, Icons.radio_button_checked,
                    AppStrings.navTasbeh),
                _buildNavItem(4, Icons.settings, AppStrings.navSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final active = _index == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = active
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
