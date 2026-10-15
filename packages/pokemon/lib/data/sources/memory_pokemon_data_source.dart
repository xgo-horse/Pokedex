import 'package:core/core.dart';
import 'package:pokemon/data/sources/local_pokemon_data_source.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

/// In-memory [LocalPokemonDataSource] for platforms where Drift is unavailable
/// (e.g. Flutter web without wasm setup). Cache is session-scoped.
final class MemoryPokemonDataSource implements LocalPokemonDataSource {
  MemoryPokemonDataSource({
    this.cacheTtl = const Duration(hours: 24),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration cacheTtl;
  final DateTime Function() _clock;

  final Map<int, _CachedPokemon> _pokemonById = {};
  final Map<String, _CachedPage> _pagesByKey = {};

  String _cacheTypeName(Type? type) => type?.name ?? '';

  String _pageKey({required int limit, required int offset, Type? type}) =>
      '$limit|$offset|${_cacheTypeName(type)}';

  bool _isExpired(DateTime cachedAt) {
    final age = _clock().difference(cachedAt);
    return age >= cacheTtl;
  }

  @override
  Future<Either<Failure, PokemonListPage?>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
  }) async {
    final cached =
        _pagesByKey[_pageKey(limit: limit, offset: offset, type: type)];
    if (cached == null || _isExpired(cached.cachedAt)) {
      return const Right(null);
    }

    final pokemon = <Pokemon>[];
    for (final id in cached.ids) {
      final entry = _pokemonById[id];
      if (entry == null || _isExpired(entry.cachedAt)) {
        return const Right(null);
      }
      pokemon.add(entry.pokemon);
    }

    return Right(
      PokemonListPage(
        pokemon: pokemon,
        totalCount: cached.totalCount,
        hasNext: cached.hasNext,
      ),
    );
  }

  @override
  Future<Either<Failure, Pokemon?>> getPokemonById(int id) async {
    final entry = _pokemonById[id];
    if (entry == null || _isExpired(entry.cachedAt)) {
      return const Right(null);
    }
    return Right(entry.pokemon);
  }

  @override
  Future<Either<Failure, void>> savePokemonPage({
    required int limit,
    required int offset,
    Type? type,
    required PokemonListPage page,
  }) async {
    final now = _clock();
    for (final pokemon in page.pokemon) {
      _pokemonById[pokemon.id] = _CachedPokemon(
        pokemon: pokemon,
        cachedAt: now,
      );
    }
    _pagesByKey[_pageKey(
      limit: limit,
      offset: offset,
      type: type,
    )] = _CachedPage(
      ids: page.pokemon.map((p) => p.id).toList(growable: false),
      totalCount: page.totalCount,
      hasNext: page.hasNext,
      cachedAt: now,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> savePokemon(Pokemon pokemon) async {
    _pokemonById[pokemon.id] = _CachedPokemon(
      pokemon: pokemon,
      cachedAt: _clock(),
    );
    return const Right(null);
  }
}

final class _CachedPokemon {
  const _CachedPokemon({required this.pokemon, required this.cachedAt});

  final Pokemon pokemon;
  final DateTime cachedAt;
}

final class _CachedPage {
  const _CachedPage({
    required this.ids,
    required this.totalCount,
    required this.hasNext,
    required this.cachedAt,
  });

  final List<int> ids;
  final int totalCount;
  final bool hasNext;
  final DateTime cachedAt;
}
