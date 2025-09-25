import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Map<String, String>> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final geocodeUrl =
          "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude";

      final geocodeResponse = await http.get(
        Uri.parse(geocodeUrl),
        headers: {
          'User-Agent': 'FlutterApp/1.0', // Required by Nominatim policy
        },
      );

      if (geocodeResponse.statusCode != 200) {
        return {
          "city": "Unknown",
          "pincode": "Unknown",
          "city_id": "Unknown",
          "error":
              "Geocoding API failed with status ${geocodeResponse.statusCode}",
        };
      }

      final data = json.decode(geocodeResponse.body);
      final address = data['address'] ?? {};

      String city =
          address['city'] ??
          address['town'] ??
          address['village'] ??
          address['county'] ??
          "Unknown";

      String pincode = address['postcode'] ?? "Unknown";
      String state = address['state'] ?? "Unknown";
      String country = address['country'] ?? "Unknown";

      return {
        "city": city,
        "pincode": pincode,
        "state": state,
        "country": country,
        "city_id": city.toLowerCase().replaceAll(' ', '_'),
      };
    } catch (e) {
      return {
        "city": "Unknown",
        "pincode": "Unknown",
        "city_id": "Unknown",
        "error": e.toString(),
      };
    }
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, String>> getCurrentCity() async {
    final position = await getCurrentLocation();
    if (position != null) {
      return await getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );
    }
    return {
      "city": "Unknown",
      "pincode": "Unknown",
      "city_id": "Unknown",
      "error": "Unable to get current location",
    };
  }
}
