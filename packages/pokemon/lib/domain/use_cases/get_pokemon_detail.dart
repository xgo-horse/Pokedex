import 'package:core/core.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';

class GetPokemonDetail {
  const GetPokemonDetail(this._repository);

  final PokemonRepository _repository;

  Future<Either<Failure, Pokemon>> call(int id) =>
      _repository.getPokemonById(id);
}
