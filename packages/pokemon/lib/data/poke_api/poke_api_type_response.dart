import 'package:pokemon/data/poke_api/poke_api_pokemon_list_response.dart';

final class PokeApiTypeResponse {
  const PokeApiTypeResponse({required this.pokemon});

  final List<PokeApiPokemonSummary> pokemon;

  factory PokeApiTypeResponse.fromJson(Map<String, dynamic> json) {
    final pokemonJson = json['pokemon'] as List<dynamic>? ?? const [];
    return PokeApiTypeResponse(
      pokemon: pokemonJson.cast<Map<String, dynamic>>().map((entry) {
        final pokemon = entry['pokemon'] as Map<String, dynamic>;
        return PokeApiPokemonSummary.fromJson(pokemon);
      }).toList(),
    );
  }
}
