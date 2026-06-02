import 'package:dio/dio.dart';

class DioClient {
  static const String baseUrl = 'https://rickandmortyapi.com/api';
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    return Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ));
  }

  static Dio get instance => _dio;
  static Dio getDio() => _dio;
}