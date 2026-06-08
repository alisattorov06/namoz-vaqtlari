import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:namoz_vaqtlari/core/models/location_model.dart';

/// Qibla yo'nalishi boshqaruvchisi
class QiblaProvider extends ChangeNotifier {
  StreamSubscription<CompassEvent>? _compassSub;

  double? _heading; // Telefon yo'nalishi (shimolga nisbatan)
  double _qiblaDirection = 0; // Qibla yo'nalishi
  bool _hasCompass = true;
  bool _isLoading = true;

  double get heading => _heading ?? 0;
  double get qiblaDirection => _qiblaDirection;
  bool get hasCompass => _hasCompass;
  bool get isLoading => _isLoading;

  /// Qibla bilan telefon orasidagi burchak
  double get qiblaOffset {
    if (_heading == null) return 0;
    double diff = _qiblaDirection - _heading!;
    while (diff > 180) diff -= 360;
    while (diff < -180) diff += 360;
    return diff;
  }

  /// Qibla tomon yo'nalgan
  bool get isFacingQibla {
    final offset = qiblaOffset.abs();
    return offset < 5;
  }

  /// Joylashuvga ko'ra Qibla burchagini hisoblash
  void calculateQiblaDirection(LocationModel location) {
    // Makka koordinatalari
    const meccaLat = 21.4225;
    const meccaLng = 39.8262;

    final lat1 = location.latitude * (math.pi / 180);
    final lng1 = location.longitude * (math.pi / 180);
    final lat2 = meccaLat * (math.pi / 180);
    final lng2 = meccaLng * (math.pi / 180);

    final dLng = lng2 - lng1;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    var bearing = math.atan2(y, x) * (180 / math.pi);
    bearing = (bearing + 360) % 360;

    _qiblaDirection = bearing;
    notifyListeners();
  }

  /// Kompasni boshlash
  void startCompass() {
    _isLoading = true;
    notifyListeners();

    // Kompas mavjudligini tekshirish
    final isAvailable = FlutterCompass.events != null;
    _hasCompass = isAvailable;

    if (!isAvailable) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _compassSub = FlutterCompass.events!.listen(
      (CompassEvent event) {
        _heading = event.heading;
        if (_isLoading) _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _hasCompass = false;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Kompasni to'xtatish
  void stopCompass() {
    _compassSub?.cancel();
    _compassSub = null;
  }

  @override
  void dispose() {
    stopCompass();
    super.dispose();
  }
}
