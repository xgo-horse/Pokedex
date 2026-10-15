import 'package:core/core.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

abstract interface class LocalPokemonDataSource {
  Future<Either<Failure, PokemonListPage?>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
  });

  Future<Either<Failure, Pokemon?>> getPokemonById(int id);

  Future<Either<Failure, void>> savePokemonPage({
    required int limit,
    required int offset,
    Type? type,
    required PokemonListPage page,
  });

  Future<Either<Failure, void>> savePokemon(Pokemon pokemon);
}
