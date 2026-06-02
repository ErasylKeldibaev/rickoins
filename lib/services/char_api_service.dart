import 'package:dio/dio.dart';
import 'dio_client.dart';

class CharApiService {
  final Dio _dio = DioClient.getDio();

  Future<List<dynamic>> getAllCharacters() async {
    try {
      final List<int> ids = List.generate(240, (index) => index + 1);
      final String idString = ids.join(',');
      final response = await _dio.get('/character/$idString');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}