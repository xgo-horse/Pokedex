import 'dart:convert';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;

class PokeApiGraphqlClient {
  PokeApiGraphqlClient(
    this._client, {
    this.baseUrl = 'https://graphql.pokeapi.co/v1beta2',
  });

  final http.Client _client;
  final String baseUrl;

  Future<Either<Failure, Map<String, dynamic>>> query(
    String document, {
    Map<String, dynamic>? variables,
  }) async {
    final uri = Uri.parse(baseUrl);
    final body = <String, dynamic>{'query': document, 'variables': ?variables};

    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Left(
          NetworkFailure('Request failed with status ${response.statusCode}'),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const Left(UnexpectedFailure('Expected JSON object response'));
      }

      final data = decoded['data'];
      final errors = decoded['errors'];
      if (data is! Map<String, dynamic>) {
        final message = _graphqlErrorMessage(errors);
        return Left(
          UnexpectedFailure(message ?? 'GraphQL response missing data'),
        );
      }

      return Right(data);
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(e.message));
    } on FormatException catch (e) {
      return Left(UnexpectedFailure('Invalid JSON: ${e.message}'));
    }
  }

  String? _graphqlErrorMessage(Object? errors) {
    if (errors is! List || errors.isEmpty) {
      return null;
    }
    final first = errors.first;
    if (first is Map<String, dynamic>) {
      final message = first['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return 'GraphQL request failed';
  }
}
