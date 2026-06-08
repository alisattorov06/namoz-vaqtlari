import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:namoz_vaqtlari/core/constants/app_colors.dart';
import 'package:namoz_vaqtlari/core/constants/app_strings.dart';
import 'package:namoz_vaqtlari/core/services/location_service.dart';
import 'package:namoz_vaqtlari/core/services/notification_service.dart';
import 'package:namoz_vaqtlari/core/services/storage_service.dart';
import 'package:namoz_vaqtlari/core/providers/prayer_provider.dart';
import 'package:namoz_vaqtlari/features/onboarding/location_picker_sheet.dart';
import 'package:namoz_vaqtlari/shared/widgets/main_scaffold.dart';

/// Birinchi marta kirish - ruxsatlarni so'rash sahifasi
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  int _page = 0;
  final _locationService = LocationService();
  bool _isLoading = false;

  Future<void> _requestLocation() async {
    setState(() => _isLoading = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('GPS yoqilmagan. Iltimos, GPS ni yoqing.');
        setState(() => _isLoading = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Joylashuv ruxsati berilmadi');
        setState(() => _isLoading = false);
        return;
      }

      final location = await _locationService.getCurrentLocation();
      if (location != null && mounted) {
        await context.read<PrayerProvider>().setLocation(location);
        if (mounted) {
          setState(() => _isLoading = false);
          _goToNext();
        }
      } else {
        _showSnack('Joylashuv aniqlanmadi. Iltimos, qo\'lda tanlang.');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnack('Xatolik: $e');
      setState(() => _isLoading = false);
    }
  }

  void _goToNext() {
    if (_page < 2) {
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    await context.read<StorageService>().setOnboardingDone(true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: PageController(initialPage: _page),
                  onPageChanged: (p) => setState(() => _page = p),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),
              _buildIndicators(),
              const SizedBox(height: 24),
              _buildButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mosque, size: 100, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Text(
            AppStrings.welcomeTitle,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.welcomeSubtitle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildFeature(Icons.access_time, 'Aniq namoz vaqtlari'),
          _buildFeature(Icons.notifications_active, 'Bildirishnomalar va eslatmalar'),
          _buildFeature(Icons.explore, 'Qibla yo\'nalishi'),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, size: 100, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Text(
            'Joylashuvni tanlang',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Aniq namoz vaqtlarini ko\'rsatish uchun joylashuvni aniqlashimiz kerak',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _requestLocation,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.my_location),
            label: const Text('GPS orqali aniqlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _showManualLocationPicker,
            icon: const Icon(Icons.edit_location_alt, color: Colors.white),
            label: const Text(
              'Viloyat va shaharni tanlash',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active,
                size: 100, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Text(
            'Bildirishnomalar',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Namoz vaqtlari haqida o\'z vaqtida xabar berish uchun bizga ruxsat bering',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPermInfo('Bildirishnomalar', Icons.notifications),
          _buildPermInfo('Aniq budilnik', Icons.alarm),
          _buildPermInfo('Batareya sozlamalari', Icons.battery_saver),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPermInfo(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (_page > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => setState(() => _page--),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Orqaga',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_page > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_page == 2) {
                        setState(() => _isLoading = true);
                        await NotificationService.requestAllPermissions();
                        if (mounted) _finish();
                      } else if (_page == 1) {
                        if (context.read<PrayerProvider>().location == null) {
                          _showManualLocationPicker();
                        } else {
                          _goToNext();
                        }
                      } else {
                        _goToNext();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(_page == 2 ? 'Tugatish' : 'Davom etish'),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerSheet(
        onSelected: (loc) async {
          Navigator.of(context).pop();
          setState(() => _isLoading = true);
          await context.read<PrayerProvider>().setLocation(loc);
          if (mounted) {
            setState(() => _isLoading = false);
            _goToNext();
          }
        },
      ),
    );
  }
}
