import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokemon/domain/use_cases/get_pokemon_detail.dart';
import 'package:pokemon/presentation/commands/pokemon_detail_command.dart';
import 'package:pokemon/presentation/view_models/pokemon_detail_cubit.dart';
import '../../test_helpers.dart';

class _FakePokemonRepository implements PokemonRepository {
  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) async =>
      Right(testPokemon(id: id));

  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('PokemonDetailCubit', () {
    late PokemonDetailCubit cubit;

    setUp(() {
      cubit = PokemonDetailCubit(GetPokemonDetail(_FakePokemonRepository()));
    });

    tearDown(() => cubit.close());

    blocTest<PokemonDetailCubit, LoadState<Pokemon>>(
      'loads pokemon detail',
      build: () => cubit,
      act: (cubit) => cubit.execute(const LoadPokemonDetailCommand(7)),
      expect: () => [
        const LoadLoading<Pokemon>(),
        isA<LoadSuccess<Pokemon>>().having((s) => s.data.id, 'id', 7),
      ],
    );
  });
}
