import 'dart:convert';

import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:pokemon/data/local/app_database.dart';
import 'package:pokemon/data/mappers/pokemon_type_mapper.dart';
import 'package:pokemon/data/sources/local_pokemon_data_source.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

final class DriftPokemonDataSource implements LocalPokemonDataSource {
  DriftPokemonDataSource(
    this._db, {
    this.cacheTtl = const Duration(hours: 24),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Duration cacheTtl;
  final DateTime Function() _clock;

  String _cacheTypeName(Type? type) => type?.name ?? '';

  int get _nowMillis => _clock().millisecondsSinceEpoch;

  bool _isExpired(int cachedAtMillis) {
    if (cachedAtMillis <= 0) {
      return true;
    }
    final age = Duration(milliseconds: _nowMillis - cachedAtMillis);
    return age >= cacheTtl;
  }

  @override
  Future<Either<Failure, PokemonListPage?>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
  }) async {
    try {
      final cacheType = _cacheTypeName(type);
      final pageRow =
          await (_db.select(_db.pokemonPageEntries)..where(
                (t) =>
                    t.pageLimit.equals(limit) &
                    t.pageOffset.equals(offset) &
                    t.typeName.equals(cacheType),
              ))
              .getSingleOrNull();
      if (pageRow == null || _isExpired(pageRow.cachedAt)) {
        return const Right(null);
      }

      final ids = (jsonDecode(pageRow.pokemonIdsJson) as List<dynamic>)
          .cast<int>();
      final pokemon = <Pokemon>[];
      for (final id in ids) {
        final result = await getPokemonById(id);
        switch (result) {
          case Left(:final value):
            return Left(value);
          case Right(:final value):
            if (value == null) {
              return const Right(null);
            }
            pokemon.add(value);
        }
      }

      return Right(
        PokemonListPage(
          pokemon: pokemon,
          totalCount: pageRow.totalCount,
          hasNext: pageRow.hasNext,
        ),
      );
    } on Object catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Pokemon?>> getPokemonById(int id) async {
    try {
      final row = await (_db.select(
        _db.pokemonEntries,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null || _isExpired(row.cachedAt)) {
        return const Right(null);
      }
      return _rowToPokemon(row);
    } on Object catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePokemonPage({
    required int limit,
    required int offset,
    Type? type,
    required PokemonListPage page,
  }) async {
    try {
      await _db.transaction(() async {
        for (final pokemon in page.pokemon) {
          final saveResult = await savePokemon(pokemon);
          if (saveResult case Left(:final value)) {
            throw _CacheWriteException(value.message);
          }
        }

        await _db
            .into(_db.pokemonPageEntries)
            .insertOnConflictUpdate(
              PokemonPageEntriesCompanion.insert(
                pageLimit: limit,
                pageOffset: offset,
                typeName: Value(_cacheTypeName(type)),
                totalCount: page.totalCount,
                hasNext: page.hasNext,
                pokemonIdsJson: jsonEncode(
                  page.pokemon.map((p) => p.id).toList(),
                ),
                cachedAt: Value(_nowMillis),
              ),
            );
      });
      return const Right(null);
    } on _CacheWriteException catch (error) {
      return Left(UnexpectedFailure(error.message));
    } on Object catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePokemon(Pokemon pokemon) async {
    try {
      await _db
          .into(_db.pokemonEntries)
          .insertOnConflictUpdate(
            PokemonEntriesCompanion.insert(
              id: Value(pokemon.id),
              name: pokemon.name,
              imageUrl: pokemon.imageUrl.toString(),
              typesJson: jsonEncode(
                pokemon.types.map(pokemonTypeToName).toList(),
              ),
              cachedAt: Value(_nowMillis),
            ),
          );
      return const Right(null);
    } on Object catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  Either<Failure, Pokemon?> _rowToPokemon(PokemonEntry row) {
    final typeNames = (jsonDecode(row.typesJson) as List<dynamic>)
        .cast<String>();
    final types = <Type>[];
    for (final name in typeNames) {
      switch (pokemonTypeFromName(name)) {
        case Left(:final value):
          return Left(value);
        case Right(:final value):
          types.add(value);
      }
    }

    return Right(
      Pokemon(
        id: row.id,
        name: row.name,
        imageUrl: Uri.parse(row.imageUrl),
        types: types,
      ),
    );
  }
}

final class _CacheWriteException implements Exception {
  const _CacheWriteException(this.message);

  final String message;
}
