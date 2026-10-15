import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokemon/data/api/poke_api_client.dart';
import 'package:pokemon/data/sources/local_pokemon_data_source.dart';
import 'package:pokemon/data/sources/poke_api_pokemon_data_source.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

import '../../test_helpers.dart';

void main() {
  group('PokeApiPokemonDataSource', () {
    test('page hydration uses local cache and skips detail network', () async {
      final bulbasaur = testPokemon(id: 1, name: 'bulbasaur', types: [Grass()]);
      final local = _FakeLocal()..pokemonById[1] = bulbasaur;
      final detailPaths = <String>[];

      final client = PokeApiClient(
        MockClient((request) async {
          if (request.url.path.endsWith('/pokemon')) {
            return http.Response(
              jsonEncode({
                'count': 1,
                'next': null,
                'results': [
                  {
                    'name': 'bulbasaur',
                    'url': 'https://pokeapi.co/api/v2/pokemon/1/',
                  },
                ],
              }),
              200,
            );
          }
          detailPaths.add(request.url.path);
          return http.Response('unexpected detail fetch', 500);
        }),
      );

      final dataSource = PokeApiPokemonDataSource(client, local);
      final result = await dataSource.fetchPokemonPage(limit: 1, offset: 0);

      expect(result, isA<Right<Failure, PokemonListPage>>());
      final page = (result as Right<Failure, PokemonListPage>).value;
      expect(page.pokemon.single.id, 1);
      expect(detailPaths, isEmpty);
      expect(local.savePokemonCalls, 0);
    });

    test('page hydration fetches and caches missing details', () async {
      final local = _FakeLocal();
      final detailPaths = <String>[];

      final client = PokeApiClient(
        MockClient((request) async {
          if (request.url.path.endsWith('/pokemon')) {
            return http.Response(
              jsonEncode({
                'count': 1,
                'next': null,
                'results': [
                  {
                    'name': 'bulbasaur',
                    'url': 'https://pokeapi.co/api/v2/pokemon/1/',
                  },
                ],
              }),
              200,
            );
          }
          detailPaths.add(request.url.path);
          return http.Response(
            jsonEncode({
              'id': 1,
              'name': 'bulbasaur',
              'sprites': {
                'front_default': 'https://example.com/1.png',
                'other': {
                  'official-artwork': {
                    'front_default': 'https://example.com/1.png',
                  },
                },
              },
              'types': [
                {
                  'slot': 1,
                  'type': {
                    'name': 'grass',
                    'url': 'https://example.com/type/12',
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final dataSource = PokeApiPokemonDataSource(client, local);
      final result = await dataSource.fetchPokemonPage(limit: 1, offset: 0);

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect(detailPaths, contains('/api/v2/pokemon/1'));
      expect(local.savePokemonCalls, 1);
      expect(local.pokemonById[1]?.name, 'bulbasaur');
    });

    test('name search fetches catalog once and reuses cache', () async {
      final local = _FakeLocal();
      var catalogRequests = 0;

      final client = PokeApiClient(
        MockClient((request) async {
          if (request.url.path.endsWith('/pokemon') &&
              request.url.query.contains('limit=2000')) {
            catalogRequests++;
            return http.Response(
              jsonEncode({
                'count': 3,
                'next': null,
                'results': [
                  {
                    'name': 'charmander',
                    'url': 'https://pokeapi.co/api/v2/pokemon/4/',
                  },
                  {
                    'name': 'charizard',
                    'url': 'https://pokeapi.co/api/v2/pokemon/6/',
                  },
                  {
                    'name': 'squirtle',
                    'url': 'https://pokeapi.co/api/v2/pokemon/7/',
                  },
                ],
              }),
              200,
            );
          }
          if (request.url.path.endsWith('/pokemon/4')) {
            return http.Response(
              jsonEncode({
                'id': 4,
                'name': 'charmander',
                'sprites': {
                  'front_default': 'https://example.com/4.png',
                  'other': {
                    'official-artwork': {
                      'front_default': 'https://example.com/4.png',
                    },
                  },
                },
                'types': [
                  {
                    'slot': 1,
                    'type': {
                      'name': 'fire',
                      'url': 'https://example.com/type/10',
                    },
                  },
                ],
              }),
              200,
            );
          }
          if (request.url.path.endsWith('/pokemon/6')) {
            return http.Response(
              jsonEncode({
                'id': 6,
                'name': 'charizard',
                'sprites': {
                  'front_default': 'https://example.com/6.png',
                  'other': {
                    'official-artwork': {
                      'front_default': 'https://example.com/6.png',
                    },
                  },
                },
                'types': [
                  {
                    'slot': 1,
                    'type': {
                      'name': 'fire',
                      'url': 'https://example.com/type/10',
                    },
                  },
                ],
              }),
              200,
            );
          }
          return http.Response('unexpected request: ${request.url}', 500);
        }),
      );

      final dataSource = PokeApiPokemonDataSource(client, local);

      final first = await dataSource.fetchPokemonPage(
        limit: 1,
        offset: 0,
        nameQuery: 'char',
      );
      final second = await dataSource.fetchPokemonPage(
        limit: 1,
        offset: 1,
        nameQuery: 'char',
      );

      expect(first, isA<Right<Failure, PokemonListPage>>());
      expect(second, isA<Right<Failure, PokemonListPage>>());
      expect(catalogRequests, 1);
      final firstPage = (first as Right<Failure, PokemonListPage>).value;
      final secondPage = (second as Right<Failure, PokemonListPage>).value;
      expect(firstPage.pokemon.single.id, 4);
      expect(secondPage.pokemon.single.id, 6);
      expect(firstPage.hasNext, isTrue);
      expect(secondPage.hasNext, isFalse);
    });

    test('name search with type filter only returns matching type', () async {
      final local = _FakeLocal();

      final client = PokeApiClient(
        MockClient((request) async {
          if (request.url.path.endsWith('/pokemon') &&
              request.url.query.contains('limit=2000')) {
            return http.Response(
              jsonEncode({
                'count': 3,
                'next': null,
                'results': [
                  {
                    'name': 'charmander',
                    'url': 'https://pokeapi.co/api/v2/pokemon/4/',
                  },
                  {
                    'name': 'charizard',
                    'url': 'https://pokeapi.co/api/v2/pokemon/6/',
                  },
                  {
                    'name': 'squirtle',
                    'url': 'https://pokeapi.co/api/v2/pokemon/7/',
                  },
                ],
              }),
              200,
            );
          }
          if (request.url.path.endsWith('/type/water')) {
            return http.Response(
              jsonEncode({
                'pokemon': [
                  {
                    'pokemon': {
                      'name': 'squirtle',
                      'url': 'https://pokeapi.co/api/v2/pokemon/7/',
                    },
                  },
                ],
              }),
              200,
            );
          }
          if (request.url.path.endsWith('/pokemon/7')) {
            return http.Response(
              jsonEncode({
                'id': 7,
                'name': 'squirtle',
                'sprites': {
                  'front_default': 'https://example.com/7.png',
                  'other': {
                    'official-artwork': {
                      'front_default': 'https://example.com/7.png',
                    },
                  },
                },
                'types': [
                  {
                    'slot': 1,
                    'type': {
                      'name': 'water',
                      'url': 'https://example.com/type/11',
                    },
                  },
                ],
              }),
              200,
            );
          }
          return http.Response('unexpected request: ${request.url}', 500);
        }),
      );

      final dataSource = PokeApiPokemonDataSource(client, local);
      final result = await dataSource.fetchPokemonPage(
        limit: 10,
        offset: 0,
        type: Water(),
        nameQuery: 'squ',
      );

      expect(result, isA<Right<Failure, PokemonListPage>>());
      final page = (result as Right<Failure, PokemonListPage>).value;
      expect(page.pokemon, hasLength(1));
      expect(page.pokemon.single.id, 7);
    });

    test('name search with no matches returns empty page', () async {
      final local = _FakeLocal();

      final client = PokeApiClient(
        MockClient((request) async {
          if (request.url.path.endsWith('/pokemon') &&
              request.url.query.contains('limit=2000')) {
            return http.Response(
              jsonEncode({
                'count': 1,
                'next': null,
                'results': [
                  {
                    'name': 'bulbasaur',
                    'url': 'https://pokeapi.co/api/v2/pokemon/1/',
                  },
                ],
              }),
              200,
            );
          }
          return http.Response('unexpected request: ${request.url}', 500);
        }),
      );

      final dataSource = PokeApiPokemonDataSource(client, local);
      final result = await dataSource.fetchPokemonPage(
        limit: 10,
        offset: 0,
        nameQuery: 'zzz',
      );

      expect(result, isA<Right<Failure, PokemonListPage>>());
      final page = (result as Right<Failure, PokemonListPage>).value;
      expect(page.pokemon, isEmpty);
      expect(page.hasNext, isFalse);
    });
  });
}

final class _FakeLocal implements LocalPokemonDataSource {
  final Map<int, Pokemon> pokemonById = {};
  int savePokemonCalls = 0;

  @override
  Future<Either<Failure, PokemonListPage?>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
  }) async => const Right(null);

  @override
  Future<Either<Failure, Pokemon?>> getPokemonById(int id) async =>
      Right(pokemonById[id]);

  @override
  Future<Either<Failure, void>> savePokemonPage({
    required int limit,
    required int offset,
    Type? type,
    required PokemonListPage page,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> savePokemon(Pokemon pokemon) async {
    savePokemonCalls++;
    pokemonById[pokemon.id] = pokemon;
    return const Right(null);
  }
}
