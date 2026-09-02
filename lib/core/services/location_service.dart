import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final bool isMocked;
  final double accuracy;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.isMocked,
    required this.accuracy,
  });
}

class LocationService {
  /// Checks location service & permissions, then retrieves current GPS coordinates.
  static Future<LocationResult> getCurrentLocation({
    bool blockMockLocation = false,
  }) async {
    // 1. Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled on your device. Please enable GPS in Settings to record attendance.',
      );
    }

    // 2. Check and request location permissions
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied. Location is required to verify attendance.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Please enable location permissions in app settings to clock in.',
      );
    }

    // 3. Fetch current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );

    // 4. Policy check: Block mock location / fake GPS if configured
    if (blockMockLocation && position.isMocked) {
      throw Exception(
        'Mock / Fake location detected. Please disable fake GPS apps to clock in.',
      );
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      isMocked: position.isMocked,
      accuracy: position.accuracy,
    );
  }
}
