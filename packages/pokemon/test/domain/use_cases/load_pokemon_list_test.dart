import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokemon/domain/use_cases/load_pokemon_list.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import '../../test_helpers.dart';

class _FakePokemonRepository implements PokemonRepository {
  _FakePokemonRepository(this.page);

  final PokemonListPage page;
  Type? lastType;
  int? lastLimit;
  int? lastOffset;
  String? lastNameQuery;
  bool? lastForceRefresh;

  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) async {
    lastLimit = limit;
    lastOffset = offset;
    lastType = type;
    lastNameQuery = nameQuery;
    lastForceRefresh = forceRefresh;
    return Right(page);
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) {
    throw UnimplementedError();
  }
}

void main() {
  group('LoadPokemonList', () {
    test('forwards type to repository', () async {
      final repository = _FakePokemonRepository(
        testPokemonListPage(
          pokemon: [
            testPokemon(id: 4, types: [Fire()]),
            testPokemon(id: 5, types: [Fire()]),
          ],
        ),
      );
      final useCase = LoadPokemonList(repository);

      final result = await useCase(limit: 30, offset: 0, type: Fire());

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect(repository.lastType, isA<Fire>());
      expect(repository.lastLimit, 30);
      expect(repository.lastOffset, 0);
      final page = (result as Right<Failure, PokemonListPage>).value;
      expect(page.pokemon, hasLength(2));
    });

    test('forwards nameQuery to repository', () async {
      final repository = _FakePokemonRepository(
        testPokemonListPage(pokemon: [testPokemon(id: 25, name: 'pikachu')]),
      );
      final useCase = LoadPokemonList(repository);

      await useCase(limit: 30, offset: 0, nameQuery: 'pika');

      expect(repository.lastNameQuery, 'pika');
    });

    test('forwards forceRefresh to repository', () async {
      final repository = _FakePokemonRepository(
        testPokemonListPage(pokemon: [testPokemon(id: 1)]),
      );
      final useCase = LoadPokemonList(repository);

      await useCase(limit: 30, offset: 0, forceRefresh: true);

      expect(repository.lastForceRefresh, isTrue);
    });

    test('returns repository page without client-side filtering', () async {
      final repository = _FakePokemonRepository(
        testPokemonListPage(
          pokemon: [
            testPokemon(id: 4, types: [Fire()]),
            testPokemon(id: 7, types: [Water()]),
            testPokemon(id: 6, types: [Fire(), Flying()]),
          ],
        ),
      );
      final useCase = LoadPokemonList(repository);

      final result = await useCase(limit: 30, offset: 0, type: Fire());

      final page = (result as Right<Failure, PokemonListPage>).value;
      expect(page.pokemon.map((p) => p.id), [4, 7, 6]);
    });

    test('returns repository page when type is null', () async {
      final repository = _FakePokemonRepository(
        testPokemonListPage(
          pokemon: [
            testPokemon(id: 1, types: [Fire()]),
            testPokemon(id: 2, types: [Water()]),
          ],
        ),
      );
      final useCase = LoadPokemonList(repository);

      final result = await useCase(limit: 30, offset: 0);

      expect(repository.lastType, isNull);
      final page = (result as Right<Failure, PokemonListPage>).value;
      expect(page.pokemon, hasLength(2));
    });
  });
}
