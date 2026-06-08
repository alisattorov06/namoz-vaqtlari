import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Ilova haqida'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.mosque_rounded,
                  color: Colors.white, size: 56),
            ),

            const SizedBox(height: 20),

            Text(
              'Namoz Vaqtlari',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versiya 1.0.0',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 32),

            // Info cards
            _InfoCard(
              icon: Icons.info_outline_rounded,
              title: 'Maqsad',
              content:
                  'Bu ilova O\'zbekiston musulmonlariga namoz vaqtlarini to\'g\'ri va o\'z vaqtida aniqlashda yordam berish uchun yaratilgan. Barcha vaqtlar AlAdhan API orqali olinydi.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.api_rounded,
              title: 'API manba',
              content:
                  'Namoz vaqtlari aladhan.com xizmatidan olinadi. Muslim World League (MWL) hisoblash usuli va Hanafiy maktabi ishlatilgan.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.offline_bolt_rounded,
              title: 'Offline rejim',
              content:
                  'Internet bo\'lmagan holda ham oxirgi saqlangan ma\'lumotlar ishlaydi. Ilova 7 kunlik vaqtlarni avtomatik yuklab saqlab qo\'yadi.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.notifications_active_rounded,
              title: 'Bildirishnomalar',
              content:
                  'Har bir namoz uchun vaqti kirganda va 5 daqiqa oldin bildirishnoma yuboriladi. Telefon qayta yoqilganda ham ishlaydi.',
              isDark: isDark,
            ),

            const SizedBox(height: 32),

            // Features
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.darkHeaderGradient
                    : AppColors.headerGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xususiyatlar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...[
                    '🕌  6 namoz vaqti (Bomdod, Quyosh, Peshin, Asr, Shom, Xufton)',
                    '🗓  Haftalik jadval',
                    '🧭  Qibla yo\'nalishi (kompas)',
                    '📿  Tasbeh sanagich (33 sikl)',
                    '🔔  Aqlli bildirishnomalar',
                    '🌍  O\'zbekistonning barcha viloyatlari',
                    '🌙  Hijriy sana',
                    '🌓  Dark / Light rejim',
                    '📶  Offline rejim qo\'llab-quvvatlanadi',
                  ].map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Made with ❤️ for Muslim Uzbeks',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 Namoz Vaqtlari',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
