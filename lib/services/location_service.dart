import 'package:location/location.dart';

/// Exception thrown when location services are unavailable or permission denied
class LocationException implements Exception {
  final String message;
  final bool isPermissionDenied;
  final bool isServiceDisabled;

  LocationException(
    this.message, {
    this.isPermissionDenied = false,
    this.isServiceDisabled = false,
  });

  @override
  String toString() => message;
}

/// Service for handling device location with permission management
/// Extracted from WeatherService for reuse across the app
class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Location _location = Location();

  /// Get current location with full permission handling
  ///
  /// Returns [LocationData] if successful.
  /// Throws [LocationException] with user-friendly message if:
  /// - Location service is disabled and user doesn't enable it
  /// - Permission is denied by user
  Future<LocationData> getCurrentLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw LocationException(
          'Please enable location services to improve disease detection accuracy',
          isServiceDisabled: true,
        );
      }
    }

    // Check if permission is granted
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw LocationException(
          'Location permission is needed for accurate disease detection based on your region',
          isPermissionDenied: true,
        );
      }
    }

    // Permission denied forever - can't request again
    if (permissionGranted == PermissionStatus.deniedForever) {
      throw LocationException(
        'Location permission was permanently denied. Please enable it in app settings.',
        isPermissionDenied: true,
      );
    }

    // Configure for high accuracy
    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 0,
    );

    final locationData = await _location.getLocation();

    // Debug: Print location to help diagnose issues
    print(
        '📍 Location obtained: lat=${locationData.latitude}, lon=${locationData.longitude}');
    print('📍 Accuracy: ${locationData.accuracy}m');

    return locationData;
  }

  /// Check if location is available without prompting user
  ///
  /// Returns true if both service is enabled AND permission is granted
  Future<bool> isLocationAvailable() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) return false;

      PermissionStatus permission = await _location.hasPermission();
      return permission == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// Get location silently - returns null if not available instead of throwing
  ///
  /// Use this when location is optional and you don't want to prompt the user
  Future<LocationData?> getLocationSilently() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) return null;

      PermissionStatus permission = await _location.hasPermission();
      if (permission != PermissionStatus.granted) return null;

      return await _location.getLocation();
    } catch (e) {
      return null;
    }
  }
}
