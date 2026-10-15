import 'package:core/core.dart';
import 'package:pokemon/data/poke_api/poke_api_type_entry.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/type.dart';

final class PokeApiPokemonResponse {
  const PokeApiPokemonResponse({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final List<PokeApiTypeEntry> types;

  factory PokeApiPokemonResponse.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>;
    final other = sprites['other'] as Map<String, dynamic>?;
    final officialArtwork = other?['official-artwork'] as Map<String, dynamic>?;
    final imageUrl =
        officialArtwork?['front_default'] as String? ??
        sprites['front_default'] as String?;

    final typesJson = json['types'] as List<dynamic>;
    final types = typesJson
        .cast<Map<String, dynamic>>()
        .map(PokeApiTypeEntry.fromJson)
        .toList();

    return PokeApiPokemonResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: imageUrl,
      types: types,
    );
  }

  Either<Failure, Pokemon> toPokemon() {
    if (imageUrl == null) {
      return const Left(UnexpectedFailure('Missing Pokémon image URL'));
    }

    final domainTypes = <Type>[];
    for (final entry in types) {
      final result = entry.toDomainType();
      switch (result) {
        case Left(:final value):
          return Left(value);
        case Right(:final value):
          domainTypes.add(value);
      }
    }

    return Right(
      Pokemon(
        id: id,
        name: name,
        imageUrl: Uri.parse(imageUrl!),
        types: domainTypes,
      ),
    );
  }
}
