import 'package:pokemon/data/poke_api/poke_api_pokemon_list_response.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/strategies/pokemon_filter_strategy.dart';

/// Returns null when [nameQuery] is null, empty, or whitespace-only.
String? normalizeNameQuery(String? nameQuery) {
  final normalized = nameQuery?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

Pokemon nameSearchStub({required int id, required String name}) {
  return Pokemon(
    id: id,
    name: name,
    imageUrl: Uri.parse('https://pokeapi.co/placeholder/$id.png'),
    types: const [],
  );
}

List<Pokemon> rankCatalogByName(
  Iterable<PokeApiPokemonSummary> catalog,
  String nameQuery,
) {
  final stubs = catalog
      .map((entry) => nameSearchStub(id: entry.id, name: entry.name))
      .toList(growable: false);
  return FuzzyNamePokemonFilter(nameQuery).apply(stubs);
}

({List<Pokemon> page, int totalCount, bool hasNext}) paginateRankedResults({
  required List<Pokemon> ranked,
  required int limit,
  required int offset,
}) {
  final totalCount = ranked.length;
  if (offset >= totalCount) {
    return (page: const [], totalCount: totalCount, hasNext: false);
  }

  final end = offset + limit;
  final clampedEnd = end > totalCount ? totalCount : end;
  return (
    page: ranked.sublist(offset, clampedEnd),
    totalCount: totalCount,
    hasNext: clampedEnd < totalCount,
  );
}

List<PokeApiPokemonSummary> filterCatalogByIds(
  List<PokeApiPokemonSummary> catalog,
  Set<int> ids,
) {
  return catalog
      .where((entry) => ids.contains(entry.id))
      .toList(growable: false);
}
