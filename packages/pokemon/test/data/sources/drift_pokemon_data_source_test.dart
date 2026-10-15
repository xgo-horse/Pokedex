import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/data/local/app_database.dart';
import 'package:pokemon/data/sources/drift_pokemon_data_source.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';

void main() {
  late AppDatabase database;
  late DriftPokemonDataSource dataSource;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dataSource = DriftPokemonDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  Pokemon bulbasaur() => Pokemon(
    id: 1,
    name: 'bulbasaur',
    imageUrl: Uri.parse('https://example.com/1.png'),
    types: [Grass(), Poison()],
  );

  Pokemon ivysaur() => Pokemon(
    id: 2,
    name: 'ivysaur',
    imageUrl: Uri.parse('https://example.com/2.png'),
    types: [Grass(), Poison()],
  );

  test('savePokemon then getPokemonById returns cached pokemon', () async {
    final pokemon = bulbasaur();

    final saveResult = await dataSource.savePokemon(pokemon);
    expect(saveResult, isA<Right<Failure, void>>());

    final result = await dataSource.getPokemonById(1);
    expect(
      result,
      isA<Right<Failure, Pokemon?>>().having(
        (r) => (r as Right).value?.name,
        'name',
        'bulbasaur',
      ),
    );
  });

  test('getPokemonById returns null on cache miss', () async {
    final result = await dataSource.getPokemonById(999);
    expect(result, const Right<Failure, Pokemon?>(null));
  });

  test('savePokemonPage then getPokemonPage returns cached page', () async {
    final page = PokemonListPage(
      pokemon: [bulbasaur(), ivysaur()],
      totalCount: 151,
      hasNext: true,
    );

    final saveResult = await dataSource.savePokemonPage(
      limit: 2,
      offset: 0,
      page: page,
    );
    expect(saveResult, isA<Right<Failure, void>>());

    final result = await dataSource.getPokemonPage(limit: 2, offset: 0);
    switch (result) {
      case Left(:final value):
        fail('Expected cache hit, got $value');
      case Right(:final value):
        expect(value, isNotNull);
        expect(value!.pokemon.map((p) => p.id), [1, 2]);
        expect(value.totalCount, 151);
        expect(value.hasNext, isTrue);
    }
  });

  test('typed pages are cached separately from untyped pages', () async {
    final untyped = PokemonListPage(
      pokemon: [bulbasaur()],
      totalCount: 151,
      hasNext: true,
    );
    final typed = PokemonListPage(
      pokemon: [ivysaur()],
      totalCount: 20,
      hasNext: false,
    );

    await dataSource.savePokemonPage(limit: 1, offset: 0, page: untyped);
    await dataSource.savePokemonPage(
      limit: 1,
      offset: 0,
      type: Grass(),
      page: typed,
    );

    final untypedResult = await dataSource.getPokemonPage(limit: 1, offset: 0);
    final typedResult = await dataSource.getPokemonPage(
      limit: 1,
      offset: 0,
      type: Grass(),
    );

    expect(
      (untypedResult as Right<Failure, PokemonListPage?>)
          .value!
          .pokemon
          .single
          .id,
      1,
    );
    expect(
      (typedResult as Right<Failure, PokemonListPage?>)
          .value!
          .pokemon
          .single
          .id,
      2,
    );
  });

  test('getPokemonPage returns null on cache miss', () async {
    final result = await dataSource.getPokemonPage(limit: 20, offset: 40);
    expect(result, const Right<Failure, PokemonListPage?>(null));
  });

  test('getPokemonById returns null when cache entry is expired', () async {
    var now = DateTime.utc(2026, 1, 1);
    dataSource = DriftPokemonDataSource(
      database,
      cacheTtl: const Duration(hours: 24),
      clock: () => now,
    );

    await dataSource.savePokemon(bulbasaur());
    now = now.add(const Duration(hours: 25));

    final result = await dataSource.getPokemonById(1);
    expect(result, const Right<Failure, Pokemon?>(null));
  });

  test('getPokemonPage returns null when page cache is expired', () async {
    var now = DateTime.utc(2026, 1, 1);
    dataSource = DriftPokemonDataSource(
      database,
      cacheTtl: const Duration(hours: 24),
      clock: () => now,
    );

    await dataSource.savePokemonPage(
      limit: 1,
      offset: 0,
      page: PokemonListPage(
        pokemon: [bulbasaur()],
        totalCount: 1,
        hasNext: false,
      ),
    );
    now = now.add(const Duration(hours: 25));

    final result = await dataSource.getPokemonPage(limit: 1, offset: 0);
    expect(result, const Right<Failure, PokemonListPage?>(null));
  });

  test('fresh cache remains readable within ttl', () async {
    var now = DateTime.utc(2026, 1, 1);
    dataSource = DriftPokemonDataSource(
      database,
      cacheTtl: const Duration(hours: 24),
      clock: () => now,
    );

    await dataSource.savePokemon(bulbasaur());
    now = now.add(const Duration(hours: 23));

    final result = await dataSource.getPokemonById(1);
    expect(
      result,
      isA<Right<Failure, Pokemon?>>().having(
        (r) => (r as Right).value?.name,
        'name',
        'bulbasaur',
      ),
    );
  });
}
