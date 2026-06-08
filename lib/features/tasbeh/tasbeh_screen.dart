import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';

class TasbehScreen extends StatefulWidget {
  const TasbehScreen({super.key});

  @override
  State<TasbehScreen> createState() => _TasbehScreenState();
}

class _TasbehScreenState extends State<TasbehScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapCtrl;
  late Animation<double> _scaleAnim;

  int _count = 0;
  bool _vibrateEnabled = true;
  int _selectedDhikr = 0;
  final int _target = 33;

  final List<Map<String, String>> _dhikrList = [
    {'name': 'Subhanallah', 'arabic': 'سُبْحَانَ اللَّه', 'meaning': 'Alloh pok va muqaddasdir'},
    {'name': 'Alhamdulillah', 'arabic': 'الْحَمْدُ لِلَّه', 'meaning': 'Barcha hamdu sanolar Allohga'},
    {'name': 'Allahu Akbar', 'arabic': 'اللَّهُ أَكْبَر', 'meaning': 'Alloh eng ulugʻdir'},
    {'name': 'Astaghfirullah', 'arabic': 'أَسْتَغْفِرُ اللَّه', 'meaning': 'Men Allohdan kechirim soʻrayman'},
    {'name': 'La ilaha illallah', 'arabic': 'لَا إِلَٰهَ إِلَّا اللَّه', 'meaning': 'Allohdan boshqa iloh yoʻq'},
  ];

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.90,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _tapCtrl;
    _load();
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final storage = context.read<StorageService>();
    setState(() => _count = storage.getTasbehCount());
  }

  Future<void> _increment() async {
    setState(() => _count++);
    final storage = context.read<StorageService>();
    await storage.saveTasbehCount(_count);

    // Tap animation
    await _tapCtrl.reverse();
    await _tapCtrl.forward();

    // Vibration
    if (_vibrateEnabled) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        Vibration.vibrate(duration: 30, amplitude: 50);
      }
    }

    // Target reached - special vibration
    if (_count % _target == 0 && _count > 0) {
      if (_vibrateEnabled) {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) {
          Vibration.vibrate(pattern: [0, 100, 100, 100, 100, 200]);
        }
      }
    }
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Qayta boshlash'),
        content: const Text('Tasbehi hisobini nolga sifatlantirasizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ha, qayta boshlash'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (mounted) {
        setState(() => _count = 0);
        final storage = context.read<StorageService>();
        await storage.saveTasbehCount(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_count % _target) / _target;
    final cycles = _count ~/ _target;
    final currentDhikr = _dhikrList[_selectedDhikr];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbeh'),
        centerTitle: false,
        actions: [
          // Vibration toggle
          IconButton(
            icon: Icon(
              _vibrateEnabled ? Icons.vibration_rounded : Icons.phonelink_erase_rounded,
              color: _vibrateEnabled ? AppColors.primary : Colors.grey,
            ),
            onPressed: () => setState(() => _vibrateEnabled = !_vibrateEnabled),
            tooltip: 'Vibratsiya',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reset,
            tooltip: 'Qayta boshlash',
          ),
        ],
      ),
      body: Column(
        children: [
          // Dhikr selector
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _dhikrList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = _selectedDhikr == i;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDhikr = i;
                      _count = 0;
                    });
                    context.read<StorageService>().saveTasbehCount(0);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : (isDark ? AppColors.cardDark : AppColors.cardLight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _dhikrList[i]['name']!,
                      style: TextStyle(
                        color: selected ? Colors.white : null,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Arabic text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  currentDhikr['arabic']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.accent : AppColors.primary,
                    height: 1.8,
                  ),
                ),
                Text(
                  currentDhikr['name']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  currentDhikr['meaning']!,
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

          const Spacer(),

          // Progress ring + count
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_count',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (cycles > 0)
                    Text(
                      '$cycles × $_target',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    '/ $_target',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Tap button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: GestureDetector(
                onTap: _increment,
                child: Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Reset button
          TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Qayta boshlash'),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
