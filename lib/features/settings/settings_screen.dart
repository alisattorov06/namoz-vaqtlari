import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/uzbekistan_regions.dart';
import '../../core/models/location_model.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayer = context.watch<PrayerProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ── Location ──────────────────────────────────────────────────
          _SectionTitle('📍 Joylashuv'),
          _SettingsCard(
            isDark: isDark,
            children: [
              _LocationTile(prayer: prayer),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.map_rounded,
                      color: AppColors.secondary, size: 20),
                ),
                title: const Text('Viloyat va tuman tanlash',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(prayer.location.regionName.isNotEmpty
                    ? prayer.location.regionName
                    : 'Tanlanmagan'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LocationSelectorScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Notifications ──────────────────────────────────────────────
          _SectionTitle('🔔 Bildirishnomalar'),
          _SettingsCard(
            isDark: isDark,
            children: [
              ..._prayerKeys.map((entry) => Column(
                    children: [
                      _NotifTile(
                        prayerKey: entry['key']!,
                        name: entry['name']!,
                        prayer: prayer,
                      ),
                      if (entry != _prayerKeys.last)
                        const Divider(height: 1, indent: 56),
                    ],
                  )),
            ],
          ),

          const SizedBox(height: 20),

          // ── 5 daqiqa oldin ────────────────────────────────────────────
          _SectionTitle('⏰ 5 daqiqa oldin xabarnoma'),
          _SettingsCard(
            isDark: isDark,
            children: [
              ..._prayerKeys.map((entry) => Column(
                    children: [
                      _Before5Tile(
                        prayerKey: entry['key']!,
                        name: entry['name']!,
                        prayer: prayer,
                      ),
                      if (entry != _prayerKeys.last)
                        const Divider(height: 1, indent: 56),
                    ],
                  )),
            ],
          ),

          const SizedBox(height: 20),

          // ── Alarm ─────────────────────────────────────────────────────
          _SectionTitle('🔊 Alarm sozlamalari'),
          _SettingsCard(
            isDark: isDark,
            children: [
              ..._prayerKeys.map((entry) => Column(
                    children: [
                      _AlarmTile(
                        prayerKey: entry['key']!,
                        name: entry['name']!,
                        prayer: prayer,
                      ),
                      if (entry != _prayerKeys.last)
                        const Divider(height: 1, indent: 56),
                    ],
                  )),
            ],
          ),

          const SizedBox(height: 20),

          // ── Theme ─────────────────────────────────────────────────────
          _SectionTitle('🎨 Dizayn'),
          _SettingsCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.palette_rounded,
                      color: AppColors.accent, size: 20),
                ),
                title: const Text('Rejim',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(theme.themeModeLabel),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => _showThemeDialog(context, theme),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static final List<Map<String, String>> _prayerKeys = [
    {'key': 'fajr', 'name': 'Bomdod'},
    {'key': 'sunrise', 'name': 'Quyosh'},
    {'key': 'dhuhr', 'name': 'Peshin'},
    {'key': 'asr', 'name': 'Asr'},
    {'key': 'maghrib', 'name': 'Shom'},
    {'key': 'isha', 'name': 'Xufton'},
  ];

  void _showThemeDialog(BuildContext context, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejimni tanlang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              label: '☀️  Yorug\' rejim',
              selected: theme.themeMode == ThemeMode.light,
              onTap: () {
                theme.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            _ThemeOption(
              label: '🌙  Qorong\'u rejim',
              selected: theme.themeMode == ThemeMode.dark,
              onTap: () {
                theme.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            _ThemeOption(
              label: '🔄  Tizim sozlamasi',
              selected: theme.themeMode == ThemeMode.system,
              onTap: () {
                theme.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final PrayerProvider prayer;
  const _LocationTile({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.gps_fixed_rounded,
            color: AppColors.primary, size: 20),
      ),
      title: const Text('GPS orqali aniqlash',
          style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        prayer.location.isGps ? 'Faol — ${prayer.location.cityName}' : 'Faol emas',
      ),
      trailing: Switch.adaptive(
        value: prayer.location.isGps,
        activeColor: AppColors.primary,
        onChanged: (_) async {
          final ok = await prayer.useGpsLocation();
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('GPS joylashuvni aniqlab bo\'lmadi')),
            );
          }
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final String prayerKey, name;
  final PrayerProvider prayer;
  const _NotifTile(
      {required this.prayerKey, required this.name, required this.prayer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch.adaptive(
        value: prayer.notifEnabled[prayerKey] ?? true,
        activeColor: AppColors.primary,
        onChanged: (v) => prayer.setNotifEnabled(prayerKey, v),
      ),
    );
  }
}

class _Before5Tile extends StatelessWidget {
  final String prayerKey, name;
  final PrayerProvider prayer;
  const _Before5Tile(
      {required this.prayerKey, required this.name, required this.prayer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch.adaptive(
        value: prayer.before5Enabled[prayerKey] ?? true,
        activeColor: AppColors.secondary,
        onChanged: (v) => prayer.setBefore5Enabled(prayerKey, v),
      ),
    );
  }
}

class _AlarmTile extends StatelessWidget {
  final String prayerKey, name;
  final PrayerProvider prayer;
  const _AlarmTile(
      {required this.prayerKey, required this.name, required this.prayer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch.adaptive(
        value: prayer.alarmEnabled[prayerKey] ?? false,
        activeColor: AppColors.accent,
        onChanged: (v) => prayer.setAlarmEnabled(prayerKey, v),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeOption(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

// ── Location Selector ──────────────────────────────────────────────────────

class LocationSelectorScreen extends StatefulWidget {
  const LocationSelectorScreen({super.key});

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  String? _selectedRegion;
  Map<String, dynamic>? _selectedDistrict;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final regions = UzbekistanRegions.regions;
    final districts = _selectedRegion != null
        ? UzbekistanRegions.getDistricts(_selectedRegion!)
        : <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Joylashuvni tanlang'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Regions list
                Expanded(
                  flex: 4,
                  child: Container(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    child: ListView.builder(
                      itemCount: regions.length,
                      itemBuilder: (_, i) {
                        final r = regions[i];
                        final name = r['name'] as String;
                        final isSelected = _selectedRegion == name;
                        return InkWell(
                          onTap: () => setState(() {
                            _selectedRegion = name;
                            _selectedDistrict = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border(
                                left: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected ? AppColors.primary : null,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Divider
                VerticalDivider(width: 1,
                    color: isDark ? Colors.white12 : Colors.black12),

                // Districts list
                Expanded(
                  flex: 5,
                  child: districts.isEmpty
                      ? Center(
                          child: Text(
                            'Viloyat tanlang',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: districts.length + 1,
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              // Region itself as first item
                              final region = UzbekistanRegions
                                  .findRegionByName(_selectedRegion!);
                              if (region == null) return const SizedBox.shrink();
                              return _DistrictTile(
                                name: _selectedRegion!,
                                subtitle: 'Viloyat markazi',
                                isSelected: _selectedDistrict == null &&
                                    _selectedRegion != null,
                                onTap: () {
                                  setState(() => _selectedDistrict = null);
                                  _applyLocation(
                                    name: _selectedRegion!,
                                    region: _selectedRegion!,
                                    lat: (region['lat'] as num).toDouble(),
                                    lon: (region['lon'] as num).toDouble(),
                                  );
                                },
                              );
                            }
                            final d = districts[i - 1];
                            final name = d['name'] as String;
                            return _DistrictTile(
                              name: name,
                              isSelected: _selectedDistrict?['name'] == name,
                              onTap: () {
                                setState(() => _selectedDistrict = d);
                                _applyLocation(
                                  name: name,
                                  region: _selectedRegion!,
                                  lat: (d['lat'] as num).toDouble(),
                                  lon: (d['lon'] as num).toDouble(),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyLocation({
    required String name,
    required String region,
    required double lat,
    required double lon,
  }) async {
    final location = LocationModel(
      latitude: lat,
      longitude: lon,
      cityName: name,
      regionName: region,
      isGps: false,
    );
    await context.read<PrayerProvider>().updateLocation(location);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name tanlandi'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context);
    }
  }
}

class _DistrictTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  const _DistrictTile({
    required this.name,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : null,
                      fontSize: 13,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.passed),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded,
                  color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
