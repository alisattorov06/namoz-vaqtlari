class LocationModel {
  final double latitude;
  final double longitude;
  final String cityName;
  final String regionName;
  final bool isGps;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.regionName,
    this.isGps = false,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['cityName'] as String? ?? '',
      regionName: json['regionName'] as String? ?? '',
      isGps: json['isGps'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'cityName': cityName,
        'regionName': regionName,
        'isGps': isGps,
      };

  static const LocationModel tashkent = LocationModel(
    latitude: 41.2995,
    longitude: 69.2401,
    cityName: 'Toshkent',
    regionName: 'Toshkent shahri',
  );

  @override
  String toString() => '$cityName ($regionName)';
}
