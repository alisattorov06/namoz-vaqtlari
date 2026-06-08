import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class QiblaProvider extends ChangeNotifier {
  final StorageService _storage;

  double? _qiblaDirection;
  double? _compassHeading;
  bool _hasCompass = false;
  bool _loading = false;
  String? _error;

  QiblaProvider(this._storage) {
    _loadCached();
  }

  double? get qiblaDirection => _qiblaDirection;
  double? get compassHeading => _compassHeading;
  bool get hasCompass => _hasCompass;
  bool get loading => _loading;
  String? get error => _error;

  /// Kompasga qibla yo'nalishini hisoblash
  double? get qiblaAngle {
    if (_qiblaDirection == null || _compassHeading == null) return null;
    return _qiblaDirection! - _compassHeading!;
  }

  void _loadCached() {
    _qiblaDirection = _storage.getQiblaDirection();
  }

  Future<void> initialize(double lat, double lon) async {
    _loading = true;
    notifyListeners();

    // API dan yo'nalish olish
    final direction = await ApiService.getQiblaDirection(
      latitude: lat,
      longitude: lon,
    );

    if (direction != null) {
      _qiblaDirection = direction;
      await _storage.saveQiblaDirection(direction);
    } else if (_qiblaDirection == null) {
      _error = 'Qibla yo\'nalishini aniqlab bo\'lmadi';
    }

    // Kompasni ishga tushirish
    _startCompass();

    _loading = false;
    notifyListeners();
  }

  void _startCompass() {
    try {
      FlutterCompass.events?.listen((event) {
        if (event.heading != null) {
          _hasCompass = true;
          _compassHeading = event.heading;
          notifyListeners();
        }
      });
    } catch (_) {
      _hasCompass = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
