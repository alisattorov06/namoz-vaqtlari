/// Joylashuv modeli
class LocationModel {
  final double latitude;
  final double longitude;
  final String? regionId;
  final String? districtId;
  final String cityName;
  final String? regionName;
  final bool isGps;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.regionId,
    this.districtId,
    this.regionName,
    this.isGps = false,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'regionId': regionId,
        'districtId': districtId,
        'cityName': cityName,
        'regionName': regionName,
        'isGps': isGps,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        regionId: json['regionId'] as String?,
        districtId: json['districtId'] as String?,
        cityName: json['cityName'] as String,
        regionName: json['regionName'] as String?,
        isGps: json['isGps'] as bool? ?? false,
      );

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? regionId,
    String? districtId,
    String? cityName,
    String? regionName,
    bool? isGps,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      regionId: regionId ?? this.regionId,
      districtId: districtId ?? this.districtId,
      cityName: cityName ?? this.cityName,
      regionName: regionName ?? this.regionName,
      isGps: isGps ?? this.isGps,
    );
  }
}
