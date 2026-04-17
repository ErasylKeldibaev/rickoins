import 'package:dio/dio.dart';

import '../models/character_model.dart';

class CharacterService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://rickandmortyapi.com/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<CharacterModel>> fetchCharacters() async {
    final response = await _dio.get('/character');

    final results = response.data['results'] as List<dynamic>? ?? [];

    return results
        .map((e) => CharacterModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}