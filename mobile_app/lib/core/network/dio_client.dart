import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Global Dio client configured with factory constructor and base options.
class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio dio;

  /// Global factory constructor returning the configured singleton
  /// or wrapping a custom Dio instance (ideal for mocking/testing).
  factory DioClient({Dio? customDio}) {
    if (customDio != null) {
      return DioClient._withDio(customDio);
    }
    return _instance;
  }

  DioClient._withDio(this.dio);

  DioClient._internal()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 60),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }
}
