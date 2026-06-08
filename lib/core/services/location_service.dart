import 'package:geolocator/geolocator.dart';
import 'package:namoz_vaqtlari/core/models/location_model.dart';

/// Joylashuv xizmati
class LocationService {
  /// GPS orqali hozirgi joylashuvni aniqlash
  Future<LocationModel?> getCurrentLocation() async {
    try {
      // Xizmat yoqilganmi
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Ruxsat bor-yo'qligini tekshirish
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Joylashuvni olish
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'Aniqlangan joylashuv',
        isGps: true,
      );
    } catch (e) {
      return null;
    }
  }

  /// Ruxsat so'rash
  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// GPS yoqilganmi
  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
