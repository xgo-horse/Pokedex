import 'package:core/core.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';

class LoadPokemonList {
  const LoadPokemonList(this._repository);

  final PokemonRepository _repository;

  Future<Either<Failure, PokemonListPage>> call({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) => _repository.getPokemonPage(
    limit: limit,
    offset: offset,
    type: type,
    nameQuery: nameQuery,
    forceRefresh: forceRefresh,
  );
}
