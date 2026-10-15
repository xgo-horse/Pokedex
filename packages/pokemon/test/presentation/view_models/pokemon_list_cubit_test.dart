import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokemon/domain/use_cases/load_pokemon_list.dart';
import 'package:pokemon/presentation/commands/pokemon_list_command.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_cubit.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_state.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import '../../test_helpers.dart';

class _FakePokemonRepository implements PokemonRepository {
  _FakePokemonRepository(this.pages);

  final List<PokemonListPage> pages;
  var callCount = 0;
  Type? lastType;
  String? lastNameQuery;
  int? lastOffset;
  bool? lastForceRefresh;

  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) async {
    lastType = type;
    lastNameQuery = nameQuery;
    lastOffset = offset;
    lastForceRefresh = forceRefresh;
    final page = pages[callCount.clamp(0, pages.length - 1)];
    callCount++;
    if (type == null) {
      return Right(page);
    }
    return Right(
      PokemonListPage(
        pokemon: page.pokemon
            .where((p) => p.types.any((t) => t.name == type.name))
            .toList(),
        totalCount: page.totalCount,
        hasNext: page.hasNext,
      ),
    );
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) {
    throw UnimplementedError();
  }
}

void main() {
  group('PokemonListCubit', () {
    late _FakePokemonRepository repository;
    late LoadPokemonList loadPokemonList;
    late PokemonListCubit cubit;

    setUp(() {
      repository = _FakePokemonRepository([
        testPokemonListPage(
          pokemon: [
            testPokemon(id: 1, types: [Fire()]),
            testPokemon(id: 2, types: [Water()]),
          ],
          hasNext: true,
        ),
        testPokemonListPage(
          pokemon: [
            testPokemon(id: 3, types: [Fire()]),
          ],
          hasNext: false,
        ),
      ]);
      loadPokemonList = LoadPokemonList(repository);
      cubit = PokemonListCubit(loadPokemonList);
    });

    tearDown(() => cubit.close());

    blocTest<PokemonListCubit, PokemonListState>(
      'loads pokemon on LoadPokemonListCommand',
      build: () => cubit,
      act: (cubit) => cubit.execute(const LoadPokemonListCommand()),
      expect: () => [
        isA<PokemonListSuccess>()
            .having((s) => s.isReloading, 'isReloading', isTrue)
            .having((s) => s.pokemon, 'pokemon', isEmpty),
        isA<PokemonListSuccess>()
            .having((s) => s.pokemon, 'pokemon', hasLength(2))
            .having((s) => s.fetchOffset, 'fetchOffset', 30)
            .having((s) => s.hasNext, 'hasNext', isTrue)
            .having((s) => s.isReloading, 'isReloading', isFalse),
      ],
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'refresh preserves type and force-refreshes',
      build: () => cubit,
      seed: () => PokemonListSuccess(
        pokemon: [
          testPokemon(id: 1, types: [Fire()]),
        ],
        hasNext: false,
        fetchOffset: 30,
        selectedType: Fire(),
      ),
      act: (cubit) => cubit.execute(const RefreshPokemonListCommand()),
      expect: () => [
        isA<PokemonListSuccess>()
            .having((s) => s.isReloading, 'isReloading', isTrue)
            .having((s) => s.selectedType, 'selectedType', isA<Fire>()),
        isA<PokemonListSuccess>()
            .having((s) => s.selectedType, 'selectedType', isA<Fire>())
            .having((s) => s.isReloading, 'isReloading', isFalse),
      ],
      verify: (_) {
        expect(repository.lastForceRefresh, isTrue);
        expect(repository.lastType, isA<Fire>());
      },
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'refresh preserves search query',
      build: () => cubit,
      seed: () => PokemonListSuccess(
        pokemon: [testPokemon(id: 25, name: 'pikachu')],
        hasNext: false,
        fetchOffset: 30,
        selectedType: Fire(),
        searchQuery: 'pika',
      ),
      act: (cubit) => cubit.execute(const RefreshPokemonListCommand()),
      expect: () => [
        isA<PokemonListSuccess>()
            .having((s) => s.searchQuery, 'searchQuery', 'pika')
            .having((s) => s.isReloading, 'isReloading', isTrue),
        isA<PokemonListSuccess>()
            .having((s) => s.searchQuery, 'searchQuery', 'pika')
            .having((s) => s.isReloading, 'isReloading', isFalse),
      ],
      verify: (_) {
        expect(repository.lastNameQuery, 'pika');
        expect(repository.lastType, isA<Fire>());
      },
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'filters pokemon on FilterPokemonListCommand',
      build: () => cubit,
      act: (cubit) => cubit.execute(FilterPokemonListCommand(Fire())),
      expect: () => [
        isA<PokemonListSuccess>()
            .having((s) => s.isReloading, 'isReloading', isTrue)
            .having((s) => s.selectedType, 'selectedType', isA<Fire>()),
        isA<PokemonListSuccess>()
            .having((s) => s.pokemon, 'pokemon', hasLength(1))
            .having((s) => s.selectedType, 'selectedType', isA<Fire>())
            .having((s) => s.isReloading, 'isReloading', isFalse),
      ],
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'filter after search preserves search query',
      build: () => cubit,
      seed: () => PokemonListSuccess(
        pokemon: [testPokemon(id: 25, name: 'pikachu')],
        hasNext: false,
        fetchOffset: 30,
        searchQuery: 'pika',
      ),
      act: (cubit) => cubit.execute(FilterPokemonListCommand(Fire())),
      expect: () => [
        isA<PokemonListSuccess>()
            .having((s) => s.searchQuery, 'searchQuery', 'pika')
            .having((s) => s.selectedType, 'selectedType', isA<Fire>()),
        isA<PokemonListSuccess>()
            .having((s) => s.searchQuery, 'searchQuery', 'pika')
            .having((s) => s.selectedType, 'selectedType', isA<Fire>()),
      ],
      verify: (_) {
        expect(repository.lastNameQuery, 'pika');
        expect(repository.lastType, isA<Fire>());
      },
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'search resets list and emits searchQuery',
      build: () => cubit,
      seed: () => PokemonListSuccess(
        pokemon: [testPokemon(id: 1), testPokemon(id: 2)],
        hasNext: true,
        fetchOffset: 60,
        selectedType: Fire(),
      ),
      act: (cubit) => cubit.execute(const SearchPokemonListCommand('char')),
      expect: () => [
        isA<PokemonListSuccess>()
            .having((s) => s.isReloading, 'isReloading', isTrue)
            .having((s) => s.searchQuery, 'searchQuery', 'char')
            .having((s) => s.selectedType, 'selectedType', isA<Fire>())
            .having((s) => s.fetchOffset, 'fetchOffset', 0),
        isA<PokemonListSuccess>()
            .having((s) => s.searchQuery, 'searchQuery', 'char')
            .having((s) => s.fetchOffset, 'fetchOffset', 30)
            .having((s) => s.isReloading, 'isReloading', isFalse),
      ],
      verify: (_) {
        expect(repository.lastNameQuery, 'char');
        expect(repository.lastType, isA<Fire>());
        expect(repository.lastOffset, 0);
      },
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'loads more pokemon on LoadMorePokemonListCommand',
      build: () => PokemonListCubit(
        LoadPokemonList(
          _OffsetAwareFakeRepository(
            loadMorePage: testPokemonListPage(
              pokemon: [testPokemon(id: 3)],
              hasNext: false,
            ),
          ),
        ),
      ),
      seed: () => PokemonListSuccess(
        pokemon: [testPokemon(id: 1)],
        hasNext: true,
        fetchOffset: 30,
      ),
      act: (cubit) => cubit.execute(const LoadMorePokemonListCommand()),
      expect: () => [
        isA<PokemonListSuccess>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          isTrue,
        ),
        isA<PokemonListSuccess>()
            .having((s) => s.pokemon, 'pokemon', hasLength(2))
            .having((s) => s.fetchOffset, 'fetchOffset', 60),
      ],
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'load-more with search passes nameQuery and appends results',
      build: () {
        final repo = _OffsetAwareFakeRepository(
          loadMorePage: testPokemonListPage(
            pokemon: [testPokemon(id: 6, name: 'charizard')],
            hasNext: false,
          ),
        );
        return PokemonListCubit(LoadPokemonList(repo));
      },
      seed: () => PokemonListSuccess(
        pokemon: [testPokemon(id: 4, name: 'charmander')],
        hasNext: true,
        fetchOffset: 30,
        searchQuery: 'char',
      ),
      act: (cubit) => cubit.execute(const LoadMorePokemonListCommand()),
      expect: () => [
        isA<PokemonListSuccess>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          isTrue,
        ),
        isA<PokemonListSuccess>()
            .having((s) => s.pokemon, 'pokemon', hasLength(2))
            .having((s) => s.searchQuery, 'searchQuery', 'char')
            .having((s) => s.fetchOffset, 'fetchOffset', 60),
      ],
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'ignores stale filter responses when a newer filter is selected',
      build: () => PokemonListCubit(LoadPokemonList(_DelayedTypeRepository())),
      act: (cubit) async {
        cubit.execute(FilterPokemonListCommand(Water()));
        await cubit.execute(FilterPokemonListCommand(Grass()));
      },
      expect: () => [
        isA<PokemonListSuccess>()
            .having((s) => s.isReloading, 'isReloading', isTrue)
            .having((s) => s.selectedType, 'selectedType', isA<Water>()),
        isA<PokemonListSuccess>()
            .having((s) => s.isReloading, 'isReloading', isTrue)
            .having((s) => s.selectedType, 'selectedType', isA<Grass>()),
        isA<PokemonListSuccess>()
            .having((s) => s.selectedType, 'selectedType', isA<Grass>())
            .having((s) => s.pokemon.single.types.single.name, 'type', 'grass'),
      ],
    );

    blocTest<PokemonListCubit, PokemonListState>(
      'ignores stale search responses when a newer search is issued',
      build: () =>
          PokemonListCubit(LoadPokemonList(_DelayedSearchRepository())),
      act: (cubit) async {
        cubit.execute(const SearchPokemonListCommand('char'));
        await cubit.execute(const SearchPokemonListCommand('pika'));
      },
      expect: () => [
        isA<PokemonListSuccess>()
            .having((s) => s.isReloading, 'isReloading', isTrue)
            .having((s) => s.searchQuery, 'searchQuery', 'char'),
        isA<PokemonListSuccess>()
            .having((s) => s.isReloading, 'isReloading', isTrue)
            .having((s) => s.searchQuery, 'searchQuery', 'pika'),
        isA<PokemonListSuccess>()
            .having((s) => s.searchQuery, 'searchQuery', 'pika')
            .having((s) => s.pokemon.single.name, 'name', 'pikachu'),
      ],
    );
  });
}

class _DelayedTypeRepository implements PokemonRepository {
  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) async {
    if (type is Water) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return Right(
        PokemonListPage(
          pokemon: [
            testPokemon(id: 7, name: 'squirtle', types: [Water()]),
          ],
          totalCount: 1,
          hasNext: false,
        ),
      );
    }
    return Right(
      PokemonListPage(
        pokemon: [
          testPokemon(id: 1, name: 'bulbasaur', types: [Grass()]),
        ],
        totalCount: 1,
        hasNext: false,
      ),
    );
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) {
    throw UnimplementedError();
  }
}

class _DelayedSearchRepository implements PokemonRepository {
  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) async {
    if (nameQuery == 'char') {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return Right(
        PokemonListPage(
          pokemon: [testPokemon(id: 4, name: 'charmander')],
          totalCount: 1,
          hasNext: false,
        ),
      );
    }
    return Right(
      PokemonListPage(
        pokemon: [testPokemon(id: 25, name: 'pikachu')],
        totalCount: 1,
        hasNext: false,
      ),
    );
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) {
    throw UnimplementedError();
  }
}

class _OffsetAwareFakeRepository implements PokemonRepository {
  _OffsetAwareFakeRepository({required this.loadMorePage});

  final PokemonListPage loadMorePage;
  String? lastNameQuery;

  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) async {
    lastNameQuery = nameQuery;
    return Right(loadMorePage);
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) {
    throw UnimplementedError();
  }
}
