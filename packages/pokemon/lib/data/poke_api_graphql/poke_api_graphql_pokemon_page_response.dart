import 'package:core/core.dart';
import 'package:pokemon/data/poke_api_graphql/poke_api_graphql_pokemon.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';

final class PokeApiGraphqlPokemonPageResponse {
  const PokeApiGraphqlPokemonPageResponse({
    required this.pokemon,
    required this.totalCount,
  });

  final List<PokeApiGraphqlPokemon> pokemon;
  final int totalCount;

  factory PokeApiGraphqlPokemonPageResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final pokemonJson = json['pokemon'] as List<dynamic>? ?? const [];
    final aggregate = json['pokemon_aggregate'] as Map<String, dynamic>?;
    final aggregateData = aggregate?['aggregate'] as Map<String, dynamic>?;
    final totalCount = aggregateData?['count'] as int? ?? pokemonJson.length;

    return PokeApiGraphqlPokemonPageResponse(
      pokemon: pokemonJson
          .cast<Map<String, dynamic>>()
          .map(PokeApiGraphqlPokemon.fromJson)
          .toList(),
      totalCount: totalCount,
    );
  }

  Either<Failure, PokemonListPage> toPokemonListPage({required int offset}) {
    final domainPokemon = <Pokemon>[];
    for (final entry in pokemon) {
      final result = entry.toPokemon();
      switch (result) {
        case Left(:final value):
          return Left(value);
        case Right(:final value):
          domainPokemon.add(value);
      }
    }

    return Right(
      PokemonListPage(
        pokemon: domainPokemon,
        totalCount: totalCount,
        hasNext: offset + domainPokemon.length < totalCount,
      ),
    );
  }
}
