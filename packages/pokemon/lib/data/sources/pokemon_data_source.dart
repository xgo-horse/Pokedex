import 'package:core/core.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

abstract interface class PokemonDataSource {
  Future<Either<Failure, PokemonListPage>> fetchPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
  });

  Future<Either<Failure, Pokemon>> fetchPokemonById(int id);
}
