import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'jobs_models.dart';

class JobsApiClient {
  JobsApiClient({Dio? dio, this.baseUrl}) : _dio = dio ?? Dio() {
    // Add interceptor to inject Firebase token into every request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken(); // 🔑 Firebase ID token
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final String? baseUrl;

  String get _base => baseUrl ?? 'https://livoro.onrender.com';

  Future<Response<dynamic>> fetchJobs({
    String? search,
    String? q,
    String? category,
    String? service,
    String? location,
    double? lat,
    double? lng,
    double? radiusKm,
    String? onDate,
    bool? upcoming,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null && search.isNotEmpty) params['search'] = search;
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (service != null && service.isNotEmpty) params['service'] = service;
    if (location != null && location.isNotEmpty) params['location'] = location;
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (radiusKm != null) params['radiusKm'] = radiusKm;
    if (onDate != null && onDate.isNotEmpty) params['onDate'] = onDate;
    if (upcoming != null) params['upcoming'] = upcoming;

    return _dio.get('$_base/api/jobs', queryParameters: params);
  }

  Future<Response<dynamic>> fetchJobById(String id) {
    return _dio.get('$_base/api/jobs/$id');
  }

  Future<Response<dynamic>> fetchServices({int page = 1, int limit = 100}) {
    return _dio.get(
      '$_base/api/services',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Response<dynamic>> postJob(JobPostRequest jobRequest) {
    return _dio.post('$_base/api/jobs', data: jobRequest.toJson());
  }
}
