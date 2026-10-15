import 'package:core/core.dart';
import 'package:pokemon/data/api/poke_api_client.dart';
import 'package:pokemon/data/poke_api/poke_api_pokemon_list_response.dart';
import 'package:pokemon/data/poke_api/poke_api_pokemon_response.dart';
import 'package:pokemon/data/poke_api/poke_api_type_response.dart';
import 'package:pokemon/data/sources/local_pokemon_data_source.dart';
import 'package:pokemon/data/sources/pokemon_data_source.dart';
import 'package:pokemon/data/sources/pokemon_name_search.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

final class PokeApiPokemonDataSource implements PokemonDataSource {
  PokeApiPokemonDataSource(this._client, this._local);

  final PokeApiClient _client;
  final LocalPokemonDataSource _local;
  List<PokeApiPokemonSummary>? _nameCatalog;

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

    if (type != null) {
      return _fetchPokemonPageByType(type: type, limit: limit, offset: offset);
    }

    final listResult = await _client.get(
      '/pokemon?limit=$limit&offset=$offset',
    );
    final PokeApiPokemonListResponse listResponse;
    switch (listResult) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        listResponse = PokeApiPokemonListResponse.fromJson(value);
    }

    return _fetchDetailsPage(
      summaries: listResponse.results,
      totalCount: listResponse.totalCount,
      hasNext: listResponse.hasNext,
    );
  }

  Future<Either<Failure, PokemonListPage>> _fetchPokemonPageByNameSearch({
    required String nameQuery,
    required int limit,
    required int offset,
    Type? type,
  }) async {
    final catalogResult = await _loadNameCatalog();
    switch (catalogResult) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        var searchableCatalog = value;
        if (type != null) {
          final typeIdsResult = await _loadTypePokemonIds(type);
          switch (typeIdsResult) {
            case Left(:final value):
              return Left(value);
            case Right(value: final typeIdSet):
              searchableCatalog = filterCatalogByIds(value, typeIdSet);
          }
        }

        final ranked = rankCatalogByName(searchableCatalog, nameQuery);
        final slice = paginateRankedResults(
          ranked: ranked,
          limit: limit,
          offset: offset,
        );
        final summaries = slice.page
            .map(
              (pokemon) => PokeApiPokemonSummary(
                name: pokemon.name,
                url: 'https://pokeapi.co/api/v2/pokemon/${pokemon.id}/',
              ),
            )
            .toList(growable: false);

        return _fetchDetailsPage(
          summaries: summaries,
          totalCount: slice.totalCount,
          hasNext: slice.hasNext,
        );
    }
  }

  Future<Either<Failure, List<PokeApiPokemonSummary>>>
  _loadNameCatalog() async {
    if (_nameCatalog != null) {
      return Right(_nameCatalog!);
    }

    final listResult = await _client.get('/pokemon?limit=2000');
    switch (listResult) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        final response = PokeApiPokemonListResponse.fromJson(value);
        _nameCatalog = response.results;
        return Right(_nameCatalog!);
    }
  }

  Future<Either<Failure, Set<int>>> _loadTypePokemonIds(Type type) async {
    final typeResult = await _client.get('/type/${type.name}');
    switch (typeResult) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        final typeResponse = PokeApiTypeResponse.fromJson(value);
        return Right(typeResponse.pokemon.map((entry) => entry.id).toSet());
    }
  }

  Future<Either<Failure, PokemonListPage>> _fetchPokemonPageByType({
    required Type type,
    required int limit,
    required int offset,
  }) async {
    final typeResult = await _client.get('/type/${type.name}');
    final PokeApiTypeResponse typeResponse;
    switch (typeResult) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        typeResponse = PokeApiTypeResponse.fromJson(value);
    }

    final all = typeResponse.pokemon;
    final totalCount = all.length;
    if (offset >= totalCount) {
      return Right(
        PokemonListPage(
          pokemon: const [],
          totalCount: totalCount,
          hasNext: false,
        ),
      );
    }

    final end = (offset + limit).clamp(0, totalCount);
    final pageSummaries = all.sublist(offset, end);
    return _fetchDetailsPage(
      summaries: pageSummaries,
      totalCount: totalCount,
      hasNext: end < totalCount,
    );
  }

  Future<Either<Failure, PokemonListPage>> _fetchDetailsPage({
    required List<PokeApiPokemonSummary> summaries,
    required int totalCount,
    required bool hasNext,
  }) async {
    final detailResults = await Future.wait(
      summaries.map((summary) => _resolvePokemon(summary.id)),
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
        totalCount: totalCount,
        hasNext: hasNext,
      ),
    );
  }

  Future<Either<Failure, Pokemon>> _resolvePokemon(int id) async {
    final cached = await _local.getPokemonById(id);
    if (cached case Right(:final value) when value != null) {
      return Right(value);
    }

    final remote = await fetchPokemonById(id);
    if (remote case Right(:final value)) {
      await _local.savePokemon(value);
    }
    return remote;
  }

  @override
  Future<Either<Failure, Pokemon>> fetchPokemonById(int id) async {
    final result = await _client.get('/pokemon/$id');
    return switch (result) {
      Left(:final value) => Left(value),
      Right(:final value) => PokeApiPokemonResponse.fromJson(value).toPokemon(),
    };
  }
}
