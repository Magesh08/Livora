import 'package:dio/dio.dart';

class LocationApiClient {
  LocationApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<String?> reverseGeocode({required double lat, required double lng}) async {
    try {
      // Nominatim public API; for production, host your own or use a paid service
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 14,
          'addressdetails': 1,
        },
        options: Options(headers: {
          'User-Agent': 'livora-app/1.0 (reverse-geocode)'
        }),
      );
      final data = res.data as Map<String, dynamic>?;
      return data?['display_name']?.toString();
    } catch (_) {
      return null;
    }
  }
}


