import 'package:core/core.dart';
import 'package:pokemon/data/poke_api/poke_api_type_entry.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/type.dart';

final class PokeApiGraphqlPokemon {
  const PokeApiGraphqlPokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final List<PokeApiTypeEntry> types;

  factory PokeApiGraphqlPokemon.fromJson(Map<String, dynamic> json) {
    final spritesList = json['pokemonsprites'] as List<dynamic>?;
    final firstSprites = spritesList?.isNotEmpty == true
        ? spritesList!.first as Map<String, dynamic>
        : null;
    final sprites = firstSprites?['sprites'];
    final imageUrl = _imageUrlFromSprites(sprites);

    final typesJson = json['pokemontypes'] as List<dynamic>? ?? const [];
    final types = typesJson.cast<Map<String, dynamic>>().map((entry) {
      final type = entry['type'] as Map<String, dynamic>;
      return PokeApiTypeEntry(name: type['name'] as String);
    }).toList();

    return PokeApiGraphqlPokemon(
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

  static String? _imageUrlFromSprites(Object? sprites) {
    if (sprites is! Map<String, dynamic>) {
      return null;
    }
    final other = sprites['other'] as Map<String, dynamic>?;
    final officialArtwork = other?['official-artwork'] as Map<String, dynamic>?;
    return officialArtwork?['front_default'] as String? ??
        sprites['front_default'] as String?;
  }
}
