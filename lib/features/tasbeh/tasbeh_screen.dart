import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:namoz_vaqtlari/core/constants/app_colors.dart';
import 'package:namoz_vaqtlari/core/services/storage_service.dart';

/// Tasbeh sanagichi sahifasi
class TasbehScreen extends StatefulWidget {
  const TasbehScreen({super.key});

  @override
  State<TasbehScreen> createState() => _TasbehScreenState();
}

class _TasbehScreenState extends State<TasbehScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _count = 0;
  int _index = 0;
  bool _vibrate = true;
  int _target = 33;

  final List<TasbehItem> _items = [
    TasbehItem('Subhanalloh', 'سُبْحَانَ ٱللَّٰهِ'),
    TasbehItem('Alhamdulillah', 'ٱلْحَمْدُ لِلَّٰهِ'),
    TasbehItem('Allahu Akbar', 'ٱللَّٰهُ أَكْبَرُ'),
    TasbehItem('La ilaha illalloh', 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.05,
    );
    final storage = context.read<StorageService>();
    _count = storage.getTasbehCount();
    _index = storage.getTasbehIndex();
    _vibrate = storage.getTasbehVibrate();
    _target = storage.getTasbehTarget();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() => _count++);
    _animController.forward(from: 0.95);
    if (_vibrate) {
      HapticFeedback.lightImpact();
    }
    context.read<StorageService>().setTasbehCount(_count);
  }

  void _reset() {
    setState(() {
      _count = 0;
      _index = (_index + 1) % _items.length;
    });
    context.read<StorageService>().setTasbehCount(0);
    context.read<StorageService>().setTasbehIndex(_index);
    if (_vibrate) HapticFeedback.mediumImpact();
  }

  void _changeTarget(int delta) {
    setState(() {
      _target = (_target + delta).clamp(1, 1000);
    });
    context.read<StorageService>().setTasbehTarget(_target);
  }

  void _toggleVibrate() {
    setState(() => _vibrate = !_vibrate);
    context.read<StorageService>().setTasbehVibrate(_vibrate);
    if (_vibrate) HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _count / _target;
    final current = _items[_index];
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
              const SizedBox(height: 20),
              _buildSelector(),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _increment,
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (_, child) {
                        return Transform.scale(
                          scale: _animController.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Progress ring
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: CircularProgressIndicator(
                                value: progress.clamp(0, 1),
                                strokeWidth: 6,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.accent),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_count',
                                  style: const TextStyle(
                                    fontSize: 64,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '/ $_target',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildArabicText(current.arabic),
              const SizedBox(height: 16),
              _buildControls(),
              const SizedBox(height: 24),
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
            child: const Icon(Icons.radio_button_checked,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tasbeh',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _toggleVibrate,
            icon: Icon(
              _vibrate ? Icons.vibration : Icons.smartphone,
              color: _vibrate ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final selected = i == _index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_items[i].latin),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _index = i;
                  _count = 0;
                });
                context.read<StorageService>().setTasbehIndex(i);
                context.read<StorageService>().setTasbehCount(0);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Theme.of(context).cardColor,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                    color: selected ? AppColors.primary : Colors.transparent),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArabicText(String arabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        arabic,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _controlButton(
              icon: Icons.remove,
              label: '-1',
              onTap: () => setState(() {
                if (_count > 0) _count--;
                context.read<StorageService>().setTasbehCount(_count);
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Tozalash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _controlButton(
              icon: Icons.add,
              label: '+1',
              onTap: () => _increment(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TasbehItem {
  final String latin;
  final String arabic;
  const TasbehItem(this.latin, this.arabic);
}
