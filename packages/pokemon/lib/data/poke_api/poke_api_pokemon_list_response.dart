final class PokeApiPokemonSummary {
  const PokeApiPokemonSummary({required this.name, required this.url});

  final String name;
  final String url;

  factory PokeApiPokemonSummary.fromJson(Map<String, dynamic> json) {
    return PokeApiPokemonSummary(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  int get id {
    final lastSegment = url
        .split('/')
        .lastWhere((segment) => segment.isNotEmpty);
    return int.parse(lastSegment);
  }

  @override
  String toString() {
    return 'PokeApiPokemonSummary(name: $name, url: $url)';
  }
}

final class PokeApiPokemonListResponse {
  const PokeApiPokemonListResponse({
    required this.totalCount,
    required this.hasNext,
    required this.results,
  });

  final int totalCount;
  final bool hasNext;
  final List<PokeApiPokemonSummary> results;

  factory PokeApiPokemonListResponse.fromJson(Map<String, dynamic> json) {
    final resultsJson = json['results'] as List<dynamic>;
    return PokeApiPokemonListResponse(
      totalCount: json['count'] as int,
      hasNext: json['next'] != null,
      results: resultsJson
          .cast<Map<String, dynamic>>()
          .map(PokeApiPokemonSummary.fromJson)
          .toList(),
    );
  }

  @override
  String toString() {
    return 'PokeApiPokemonListResponse(totalCount: $totalCount, hasNext: $hasNext, results: $results)';
  }
}
