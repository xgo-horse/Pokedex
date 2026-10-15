import 'package:core/core.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

abstract interface class PokemonRepository {
  /// When [nameQuery] is null or blank, returns offset-paged results as today.
  ///
  /// When [nameQuery] is non-empty, the implementation resolves the name
  /// catalog, fuzzy-ranks matches, paginates ranked IDs, and hydrates details.
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Pokemon>> getPokemonById(int id);
}
