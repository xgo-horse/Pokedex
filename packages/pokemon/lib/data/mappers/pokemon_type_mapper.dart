import 'package:core/core.dart';
import 'package:pokemon/domain/models/type.dart';

Either<Failure, Type> pokemonTypeFromName(String name) => switch (name) {
  'normal' => Right(Normal()),
  'fire' => Right(Fire()),
  'water' => Right(Water()),
  'grass' => Right(Grass()),
  'electric' => Right(Electric()),
  'ice' => Right(Ice()),
  'fighting' => Right(Fighting()),
  'poison' => Right(Poison()),
  'ground' => Right(Ground()),
  'flying' => Right(Flying()),
  'psychic' => Right(Psychic()),
  'bug' => Right(Bug()),
  'rock' => Right(Rock()),
  'ghost' => Right(Ghost()),
  'dragon' => Right(Dragon()),
  'dark' => Right(Dark()),
  'steel' => Right(Steel()),
  'fairy' => Right(Fairy()),
  _ => Left(UnexpectedFailure('Unknown Pokémon type: $name')),
};

String pokemonTypeToName(Type type) => type.name;
