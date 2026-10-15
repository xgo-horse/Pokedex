import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/data/repositories/data_source_pokemon_repository.dart';
import 'package:pokemon/data/sources/local_pokemon_data_source.dart';
import 'package:pokemon/data/sources/pokemon_data_source.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

void main() {
  late _FakeRemote remote;
  late _FakeLocal local;
  late DataSourcePokemonRepository repository;

  setUp(() {
    remote = _FakeRemote();
    local = _FakeLocal();
    repository = DataSourcePokemonRepository(remote, local);
  });

  final bulbasaur = Pokemon(
    id: 1,
    name: 'bulbasaur',
    imageUrl: Uri.parse('https://example.com/1.png'),
    types: [Grass()],
  );

  final charmander = Pokemon(
    id: 4,
    name: 'charmander',
    imageUrl: Uri.parse('https://example.com/4.png'),
    types: [Fire()],
  );

  final page = PokemonListPage(
    pokemon: [bulbasaur],
    totalCount: 1,
    hasNext: false,
  );

  final firePage = PokemonListPage(
    pokemon: [charmander],
    totalCount: 1,
    hasNext: false,
  );

  group('getPokemonPage', () {
    test('returns cache hit without calling remote', () async {
      local.page = page;

      final result = await repository.getPokemonPage(limit: 20, offset: 0);

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect(remote.fetchPageCalls, 0);
      expect(local.savePageCalls, 0);
    });

    test('on miss fetches remote and saves', () async {
      remote.page = page;

      final result = await repository.getPokemonPage(limit: 20, offset: 0);

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect(remote.fetchPageCalls, 1);
      expect(local.savePageCalls, 1);
      expect(local.page, page);
    });

    test('forwards type to remote and local cache', () async {
      remote.page = firePage;

      final result = await repository.getPokemonPage(
        limit: 20,
        offset: 0,
        type: Fire(),
      );

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect(remote.lastType, isA<Fire>());
      expect(local.lastType, isA<Fire>());
      expect(local.saveType, isA<Fire>());
      expect(local.page, firePage);
    });

    test('on miss surfaces remote failure', () async {
      remote.pageFailure = const NetworkFailure('offline');

      final result = await repository.getPokemonPage(limit: 20, offset: 0);

      expect(
        result,
        isA<Left<Failure, PokemonListPage>>().having(
          (r) => (r as Left).value,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
      expect(local.savePageCalls, 0);
    });

    test('on cache read failure falls through to remote', () async {
      local.pageFailure = const UnexpectedFailure('db locked');
      remote.page = page;

      final result = await repository.getPokemonPage(limit: 20, offset: 0);

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect(remote.fetchPageCalls, 1);
      expect(local.savePageCalls, 1);
    });

    test('forceRefresh skips cache and fetches remote', () async {
      local.page = page;
      remote.page = firePage;

      final result = await repository.getPokemonPage(
        limit: 20,
        offset: 0,
        forceRefresh: true,
      );

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect(remote.fetchPageCalls, 1);
      expect(local.savePageCalls, 1);
      expect((result as Right<Failure, PokemonListPage>).value, firePage);
    });

    test('returns remote page when cache save fails', () async {
      remote.page = page;
      local.savePageFailure = const UnexpectedFailure('disk full');

      final result = await repository.getPokemonPage(limit: 20, offset: 0);

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect((result as Right<Failure, PokemonListPage>).value, page);
      expect(local.savePageCalls, 1);
    });

    test('forwards nameQuery to remote', () async {
      remote.page = page;

      await repository.getPokemonPage(
        limit: 20,
        offset: 0,
        nameQuery: 'char',
      );

      expect(remote.lastNameQuery, 'char');
    });

    test('name search bypasses cache read and write', () async {
      local.page = page;
      remote.page = firePage;

      final result = await repository.getPokemonPage(
        limit: 20,
        offset: 0,
        nameQuery: 'char',
      );

      expect(result, isA<Right<Failure, PokemonListPage>>());
      expect(remote.fetchPageCalls, 1);
      expect(local.savePageCalls, 0);
      expect(local.page, page);
    });
  });

  group('getPokemonById', () {
    test('returns cache hit without calling remote', () async {
      local.pokemonById[1] = bulbasaur;

      final result = await repository.getPokemonById(1);

      expect(result, isA<Right<Failure, Pokemon>>());
      expect(remote.fetchByIdCalls, 0);
      expect(local.savePokemonCalls, 0);
    });

    test('on miss fetches remote and saves', () async {
      remote.pokemonById[1] = bulbasaur;

      final result = await repository.getPokemonById(1);

      expect(result, isA<Right<Failure, Pokemon>>());
      expect(remote.fetchByIdCalls, 1);
      expect(local.savePokemonCalls, 1);
      expect(local.pokemonById[1], bulbasaur);
    });

    test('on miss surfaces remote failure', () async {
      remote.byIdFailure = const NetworkFailure('offline');

      final result = await repository.getPokemonById(1);

      expect(
        result,
        isA<Left<Failure, Pokemon>>().having(
          (r) => (r as Left).value,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
      expect(local.savePokemonCalls, 0);
    });

    test('on cache read failure falls through to remote', () async {
      local.byIdFailure = const UnexpectedFailure('db locked');
      remote.pokemonById[1] = bulbasaur;

      final result = await repository.getPokemonById(1);

      expect(result, isA<Right<Failure, Pokemon>>());
      expect(remote.fetchByIdCalls, 1);
      expect(local.savePokemonCalls, 1);
    });

    test('returns remote pokemon when cache save fails', () async {
      remote.pokemonById[1] = bulbasaur;
      local.savePokemonFailure = const UnexpectedFailure('disk full');

      final result = await repository.getPokemonById(1);

      expect(result, isA<Right<Failure, Pokemon>>());
      expect((result as Right<Failure, Pokemon>).value, bulbasaur);
      expect(local.savePokemonCalls, 1);
    });
  });
}

final class _FakeRemote implements PokemonDataSource {
  PokemonListPage? page;
  Failure? pageFailure;
  final Map<int, Pokemon> pokemonById = {};
  Failure? byIdFailure;
  int fetchPageCalls = 0;
  int fetchByIdCalls = 0;
  Type? lastType;
  String? lastNameQuery;

  @override
  Future<Either<Failure, PokemonListPage>> fetchPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
  }) async {
    fetchPageCalls++;
    lastType = type;
    lastNameQuery = nameQuery;
    if (pageFailure != null) {
      return Left(pageFailure!);
    }
    return Right(page!);
  }

  @override
  Future<Either<Failure, Pokemon>> fetchPokemonById(int id) async {
    fetchByIdCalls++;
    if (byIdFailure != null) {
      return Left(byIdFailure!);
    }
    return Right(pokemonById[id]!);
  }
}

final class _FakeLocal implements LocalPokemonDataSource {
  PokemonListPage? page;
  Failure? pageFailure;
  final Map<int, Pokemon> pokemonById = {};
  Failure? byIdFailure;
  Failure? savePageFailure;
  Failure? savePokemonFailure;
  int savePageCalls = 0;
  int savePokemonCalls = 0;
  Type? lastType;
  Type? saveType;

  @override
  Future<Either<Failure, PokemonListPage?>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
  }) async {
    lastType = type;
    if (pageFailure != null) {
      return Left(pageFailure!);
    }
    return Right(page);
  }

  @override
  Future<Either<Failure, Pokemon?>> getPokemonById(int id) async {
    if (byIdFailure != null) {
      return Left(byIdFailure!);
    }
    return Right(pokemonById[id]);
  }

  @override
  Future<Either<Failure, void>> savePokemonPage({
    required int limit,
    required int offset,
    Type? type,
    required PokemonListPage page,
  }) async {
    savePageCalls++;
    saveType = type;
    if (savePageFailure != null) {
      return Left(savePageFailure!);
    }
    this.page = page;
    for (final pokemon in page.pokemon) {
      pokemonById[pokemon.id] = pokemon;
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> savePokemon(Pokemon pokemon) async {
    savePokemonCalls++;
    if (savePokemonFailure != null) {
      return Left(savePokemonFailure!);
    }
    pokemonById[pokemon.id] = pokemon;
    return const Right(null);
  }
}
