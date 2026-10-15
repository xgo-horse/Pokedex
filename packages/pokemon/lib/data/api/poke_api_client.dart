import 'dart:convert';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;

class PokeApiClient {
  PokeApiClient(this._client, {this.baseUrl = 'https://pokeapi.co/api/v2'});

  final http.Client _client;
  final String baseUrl;

  Future<Either<Failure, Map<String, dynamic>>> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Left(
          NetworkFailure('Request failed with status ${response.statusCode}'),
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const Left(UnexpectedFailure('Expected JSON object response'));
      }
      return Right(decoded);
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(e.message));
    } on FormatException catch (e) {
      return Left(UnexpectedFailure('Invalid JSON: ${e.message}'));
    }
  }
}
