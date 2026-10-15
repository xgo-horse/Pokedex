import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/strategies/pokemon_filter_strategy.dart';
import '../../test_helpers.dart';

void main() {
  group('AllPokemonFilter', () {
    test('returns all pokemon', () {
      const filter = AllPokemonFilter();
      final pokemon = [
        testPokemon(id: 1, types: [Fire()]),
        testPokemon(id: 2, types: [Water()]),
      ];

      expect(filter.apply(pokemon), pokemon);
    });
  });

  group('TypePokemonFilter', () {
    test('returns only pokemon matching the type', () {
      final filter = TypePokemonFilter(Fire());
      final pokemon = [
        testPokemon(id: 1, types: [Fire()]),
        testPokemon(id: 2, types: [Water()]),
        testPokemon(id: 3, types: [Fire(), Flying()]),
      ];

      final result = filter.apply(pokemon);

      expect(result, hasLength(2));
      expect(result.map((p) => p.id), [1, 3]);
    });
  });

  group('FuzzyNamePokemonFilter', () {
    final catalog = [
      testPokemon(id: 4, name: 'charmander'),
      testPokemon(id: 6, name: 'charizard'),
      testPokemon(id: 25, name: 'pikachu'),
      testPokemon(id: 122, name: 'mr-mime'),
      testPokemon(id: 150, name: 'mewtwo'),
    ];

    test('prefix query ranks char matches above unrelated pokemon', () {
      const filter = FuzzyNamePokemonFilter('char');
      final pokemon = [...catalog, testPokemon(id: 7, name: 'squirtle')];

      final result = filter.apply(pokemon);

      expect(result.map((p) => p.id), [4, 6]);
    });

    test('typo query matches close names above threshold', () {
      const filter = FuzzyNamePokemonFilter('pikach');
      final pokemon = [
        testPokemon(id: 25, name: 'pikachu'),
        testPokemon(id: 26, name: 'raichu'),
      ];

      final result = filter.apply(pokemon);

      expect(result, hasLength(1));
      expect(result.single.id, 25);
    });

    test('hyphenated name matches query with spaces', () {
      const filter = FuzzyNamePokemonFilter('mr mime');

      final result = filter.apply(catalog);

      expect(result.map((p) => p.id), contains(122));
    });

    test('query with no matches returns empty list', () {
      const filter = FuzzyNamePokemonFilter('zzz');

      final result = filter.apply(catalog);

      expect(result, isEmpty);
    });

    test('whitespace-only query is a no-op', () {
      const filter = FuzzyNamePokemonFilter('   ');
      final pokemon = [
        testPokemon(id: 1, name: 'bulbasaur'),
        testPokemon(id: 2, name: 'ivysaur'),
      ];

      final result = filter.apply(pokemon);

      expect(result, pokemon);
    });

    test('sorts by score descending then id ascending', () {
      const filter = FuzzyNamePokemonFilter('char');

      final result = filter.apply(catalog);

      expect(result.map((p) => p.id), [4, 6]);
    });
  });
}
