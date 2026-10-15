import 'package:core/core.dart';
import 'package:pokemon/data/sources/local_pokemon_data_source.dart';
import 'package:pokemon/data/sources/pokemon_data_source.dart';
import 'package:pokemon/data/sources/pokemon_name_search.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';

final class DataSourcePokemonRepository implements PokemonRepository {
  const DataSourcePokemonRepository(this._remote, this._local);

  final PokemonDataSource _remote;
  final LocalPokemonDataSource _local;

  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) async {
    final effectiveNameQuery = normalizeNameQuery(nameQuery);

    // Name searches bypass page cache in v1 — results depend on fuzzy ranking.
    if (!forceRefresh && effectiveNameQuery == null) {
      final cached = await _local.getPokemonPage(
        limit: limit,
        offset: offset,
        type: type,
      );
      if (cached case Right(:final value) when value != null) {
        return Right(value);
      }
    }

    final remote = await _remote.fetchPokemonPage(
      limit: limit,
      offset: offset,
      type: type,
      nameQuery: effectiveNameQuery,
    );
    switch (remote) {
      case Left(:final value):
        return Left(value);
      case Right(value: final page):
        if (effectiveNameQuery == null) {
          await _local.savePokemonPage(
            limit: limit,
            offset: offset,
            type: type,
            page: page,
          );
        }
        return Right(page);
    }
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) async {
    final cached = await _local.getPokemonById(id);
    if (cached case Right(:final value) when value != null) {
      return Right(value);
    }

    final remote = await _remote.fetchPokemonById(id);
    switch (remote) {
      case Left(:final value):
        return Left(value);
      case Right(value: final pokemon):
        await _local.savePokemon(pokemon);
        return Right(pokemon);
    }
  }
}
