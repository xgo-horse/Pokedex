import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/data/poke_api/poke_api_pokemon_list_response.dart';
import 'package:pokemon/data/sources/pokemon_name_search.dart';

void main() {
  group('normalizeNameQuery', () {
    test('returns null for null, empty, and whitespace', () {
      expect(normalizeNameQuery(null), isNull);
      expect(normalizeNameQuery(''), isNull);
      expect(normalizeNameQuery('   '), isNull);
    });

    test('trims non-empty queries', () {
      expect(normalizeNameQuery(' pika '), 'pika');
    });
  });

  group('rankCatalogByName', () {
    final catalog = [
      PokeApiPokemonSummary(
        name: 'charmander',
        url: 'https://pokeapi.co/api/v2/pokemon/4/',
      ),
      PokeApiPokemonSummary(
        name: 'charizard',
        url: 'https://pokeapi.co/api/v2/pokemon/6/',
      ),
      PokeApiPokemonSummary(
        name: 'squirtle',
        url: 'https://pokeapi.co/api/v2/pokemon/7/',
      ),
    ];

    test('ranks prefix matches', () {
      final ranked = rankCatalogByName(catalog, 'char');

      expect(ranked.map((p) => p.id), [4, 6]);
    });

    test('returns empty list when nothing matches', () {
      final ranked = rankCatalogByName(catalog, 'zzz');

      expect(ranked, isEmpty);
    });
  });

  group('paginateRankedResults', () {
    final ranked = [
      nameSearchStub(id: 1, name: 'bulbasaur'),
      nameSearchStub(id: 2, name: 'ivysaur'),
      nameSearchStub(id: 3, name: 'venusaur'),
    ];

    test('returns first page with hasNext true', () {
      final slice = paginateRankedResults(ranked: ranked, limit: 2, offset: 0);

      expect(slice.page.map((p) => p.id), [1, 2]);
      expect(slice.totalCount, 3);
      expect(slice.hasNext, isTrue);
    });

    test('returns later page with hasNext false', () {
      final slice = paginateRankedResults(ranked: ranked, limit: 2, offset: 2);

      expect(slice.page.map((p) => p.id), [3]);
      expect(slice.totalCount, 3);
      expect(slice.hasNext, isFalse);
    });

    test('returns empty page when offset exceeds results', () {
      final slice = paginateRankedResults(ranked: ranked, limit: 2, offset: 10);

      expect(slice.page, isEmpty);
      expect(slice.hasNext, isFalse);
    });
  });

  group('filterCatalogByIds', () {
    test('keeps only catalog entries in the id set', () {
      final catalog = [
        PokeApiPokemonSummary(
          name: 'charmander',
          url: 'https://pokeapi.co/api/v2/pokemon/4/',
        ),
        PokeApiPokemonSummary(
          name: 'squirtle',
          url: 'https://pokeapi.co/api/v2/pokemon/7/',
        ),
      ];

      final filtered = filterCatalogByIds(catalog, {4});

      expect(filtered, hasLength(1));
      expect(filtered.single.id, 4);
    });
  });
}
