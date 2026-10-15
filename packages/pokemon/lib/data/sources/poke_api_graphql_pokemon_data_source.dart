import 'package:core/core.dart';
import 'package:pokemon/data/api/poke_api_graphql_client.dart';
import 'package:pokemon/data/poke_api/poke_api_pokemon_list_response.dart';
import 'package:pokemon/data/poke_api_graphql/poke_api_graphql_pokemon.dart';
import 'package:pokemon/data/poke_api_graphql/poke_api_graphql_pokemon_page_response.dart';
import 'package:pokemon/data/sources/pokemon_data_source.dart';
import 'package:pokemon/data/sources/pokemon_name_search.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

final class PokeApiGraphqlPokemonDataSource implements PokemonDataSource {
  PokeApiGraphqlPokemonDataSource(this._client);

  final PokeApiGraphqlClient _client;
  List<PokeApiPokemonSummary>? _nameCatalog;

  static const _pokemonPageQuery = r'''
query PokemonPage($limit: Int!, $offset: Int!, $where: pokemon_bool_exp) {
  pokemon(limit: $limit, offset: $offset, where: $where, order_by: {id: asc}) {
    id
    name
    pokemonsprites {
      sprites
    }
    pokemontypes {
      type {
        name
      }
    }
  }
  pokemon_aggregate(where: $where) {
    aggregate {
      count
    }
  }
}
''';

  static const _pokemonByIdQuery = r'''
query PokemonById($id: Int!) {
  pokemon(where: { id: { _eq: $id } }, limit: 1) {
    id
    name
    pokemonsprites {
      sprites
    }
    pokemontypes {
      type {
        name
      }
    }
  }
}
''';

  static const _pokemonNameCatalogQuery = r'''
query PokemonNameCatalog($where: pokemon_bool_exp) {
  pokemon(where: $where, order_by: {id: asc}) {
    id
    name
  }
}
''';

  @override
  Future<Either<Failure, PokemonListPage>> fetchPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
  }) async {
    final effectiveNameQuery = normalizeNameQuery(nameQuery);
    if (effectiveNameQuery != null) {
      return _fetchPokemonPageByNameSearch(
        nameQuery: effectiveNameQuery,
        type: type,
        limit: limit,
        offset: offset,
      );
    }

    final result = await _client.query(
      _pokemonPageQuery,
      variables: {'limit': limit, 'offset': offset, 'where': _typeWhere(type)},
    );
    return switch (result) {
      Left(:final value) => Left(value),
      Right(:final value) => PokeApiGraphqlPokemonPageResponse.fromJson(
        value,
      ).toPokemonListPage(offset: offset),
    };
  }

  Future<Either<Failure, PokemonListPage>> _fetchPokemonPageByNameSearch({
    required String nameQuery,
    required int limit,
    required int offset,
    Type? type,
  }) async {
    final catalogResult = await _loadNameCatalog(type: type);
    switch (catalogResult) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        final ranked = rankCatalogByName(value, nameQuery);
        final slice = paginateRankedResults(
          ranked: ranked,
          limit: limit,
          offset: offset,
        );

        final detailResults = await Future.wait(
          slice.page.map((pokemon) => fetchPokemonById(pokemon.id)),
        );

        final pokemon = <Pokemon>[];
        for (final result in detailResults) {
          switch (result) {
            case Left(:final value):
              return Left(value);
            case Right(:final value):
              pokemon.add(value);
          }
        }

        return Right(
          PokemonListPage(
            pokemon: pokemon,
            totalCount: slice.totalCount,
            hasNext: slice.hasNext,
          ),
        );
    }
  }

  Future<Either<Failure, List<PokeApiPokemonSummary>>> _loadNameCatalog({
    Type? type,
  }) async {
    if (type == null && _nameCatalog != null) {
      return Right(_nameCatalog!);
    }

    final result = await _client.query(
      _pokemonNameCatalogQuery,
      variables: {'where': _typeWhere(type)},
    );
    switch (result) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        final entries = value['pokemon'] as List<dynamic>? ?? const [];
        final catalog = entries
            .cast<Map<String, dynamic>>()
            .map((entry) {
              final id = entry['id'] as int;
              final name = entry['name'] as String;
              return PokeApiPokemonSummary(
                name: name,
                url: 'https://pokeapi.co/api/v2/pokemon/$id/',
              );
            })
            .toList(growable: false);

        if (type == null) {
          _nameCatalog = catalog;
        }
        return Right(catalog);
    }
  }

  Map<String, dynamic> _typeWhere(Type? type) {
    if (type == null) {
      return const <String, dynamic>{};
    }
    return {
      'pokemontypes': {
        'type': {
          'name': {'_eq': type.name},
        },
      },
    };
  }

  @override
  Future<Either<Failure, Pokemon>> fetchPokemonById(int id) async {
    final result = await _client.query(
      _pokemonByIdQuery,
      variables: {'id': id},
    );
    return switch (result) {
      Left(:final value) => Left(value),
      Right(:final value) => _mapPokemonById(value),
    };
  }

  Either<Failure, Pokemon> _mapPokemonById(Map<String, dynamic> data) {
    final pokemonJson = data['pokemon'] as List<dynamic>? ?? const [];
    if (pokemonJson.isEmpty) {
      return const Left(UnexpectedFailure('Pokémon not found'));
    }
    return PokeApiGraphqlPokemon.fromJson(
      pokemonJson.first as Map<String, dynamic>,
    ).toPokemon();
  }
}
