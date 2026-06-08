import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService {
  /// GPS orqali joriy joylashuvni olish
  static Future<LocationModel?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Teskari geocoding - shahar nomini olish
      final cityName = await _getCityName(position.latitude, position.longitude);

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
        regionName: '',
        isGps: true,
      );
    } catch (e) {
      return null;
    }
  }

  /// Koordinatalardan shahar nomini olish (fallback)
  static Future<String> _getCityName(double lat, double lon) async {
    // Hive ichida placemark ishlatmaymiz, oddiy ism qaytaramiz
    return 'Mening joylashuvim';
  }

  /// Joylashuv ruxsati borligini tekshirish
  static Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Joylashuv xizmati yoqilganligini tekshirish
  static Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Joylashuv ruxsatini so'rash
  static Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Ikki nuqta orasidagi masofani hisoblash (km)
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
