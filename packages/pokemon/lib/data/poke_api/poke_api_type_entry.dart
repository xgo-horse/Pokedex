import 'package:core/core.dart';
import 'package:pokemon/data/mappers/pokemon_type_mapper.dart';
import 'package:pokemon/domain/models/type.dart';

final class PokeApiTypeEntry {
  const PokeApiTypeEntry({required this.name});

  final String name;

  factory PokeApiTypeEntry.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as Map<String, dynamic>;
    return PokeApiTypeEntry(name: type['name'] as String);
  }

  Either<Failure, Type> toDomainType() => pokemonTypeFromName(name);
}
