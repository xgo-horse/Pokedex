import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/type.dart';

sealed class PokemonFilterStrategy {
  const PokemonFilterStrategy();

  List<Pokemon> apply(List<Pokemon> pokemon);
}

final class AllPokemonFilter extends PokemonFilterStrategy {
  const AllPokemonFilter();

  @override
  List<Pokemon> apply(List<Pokemon> pokemon) => pokemon;
}

final class TypePokemonFilter extends PokemonFilterStrategy {
  const TypePokemonFilter(this.type);

  final Type type;

  @override
  List<Pokemon> apply(List<Pokemon> pokemon) =>
      pokemon.where((p) => p.types.any((t) => t.name == type.name)).toList();
}

final class FuzzyNamePokemonFilter extends PokemonFilterStrategy {
  const FuzzyNamePokemonFilter(this.query);

  final String query;

  static const _prefixScore = 3.0;
  static const _substringScore = 2.0;
  static const _levenshteinThreshold = 0.6;

  @override
  List<Pokemon> apply(List<Pokemon> pokemon) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return pokemon;
    }

    final scored = <({Pokemon pokemon, double score})>[];
    for (final entry in pokemon) {
      final score = _scoreName(_normalize(entry.name), normalizedQuery);
      if (score != null) {
        scored.add((pokemon: entry, score: score));
      }
    }

    scored.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return a.pokemon.id.compareTo(b.pokemon.id);
    });

    return scored.map((entry) => entry.pokemon).toList(growable: false);
  }

  static String _normalize(String value) =>
      value.toLowerCase().trim().replaceAll('-', ' ');

  static double? _scoreName(String normalizedName, String normalizedQuery) {
    if (normalizedName.startsWith(normalizedQuery)) {
      return _prefixScore;
    }
    if (normalizedName.contains(normalizedQuery)) {
      return _substringScore;
    }
    if (normalizedQuery.length < 3) {
      return null;
    }

    final ratio = _levenshteinRatio(normalizedName, normalizedQuery);
    if (ratio >= _levenshteinThreshold) {
      return ratio;
    }
    return null;
  }

  static double _levenshteinRatio(String a, String b) {
    final distance = _levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;
    if (maxLength == 0) {
      return 1;
    }
    return 1 - (distance / maxLength);
  }

  static int _levenshteinDistance(String a, String b) {
    if (a == b) {
      return 0;
    }
    if (a.isEmpty) {
      return b.length;
    }
    if (b.isEmpty) {
      return a.length;
    }

    var previous = List<int>.generate(b.length + 1, (index) => index);
    for (var i = 0; i < a.length; i++) {
      var current = List<int>.filled(b.length + 1, 0);
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final substitutionCost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        current[j + 1] = _min3(
          current[j] + 1,
          previous[j + 1] + 1,
          previous[j] + substitutionCost,
        );
      }
      previous = current;
    }
    return previous[b.length];
  }

  static int _min3(int a, int b, int c) {
    var minimum = a;
    if (b < minimum) {
      minimum = b;
    }
    if (c < minimum) {
      minimum = c;
    }
    return minimum;
  }
}
