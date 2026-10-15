import 'package:pokemon/domain/models/pokemon.dart';

class PokemonListPage {
  const PokemonListPage({
    required this.pokemon,
    required this.totalCount,
    required this.hasNext,
  });

  final List<Pokemon> pokemon;
  final int totalCount;
  final bool hasNext;
}
