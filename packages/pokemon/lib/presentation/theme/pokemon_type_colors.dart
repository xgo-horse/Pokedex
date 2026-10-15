import 'package:flutter/cupertino.dart';
import 'package:pokemon/domain/models/type.dart';

Color colorForType(Type type) => switch (type) {
  Normal() => const Color(0xFFA8A878),
  Fire() => const Color(0xFFF08030),
  Water() => const Color(0xFF6890F0),
  Grass() => const Color(0xFF78C850),
  Electric() => const Color(0xFFF8D030),
  Ice() => const Color(0xFF98D8D8),
  Fighting() => const Color(0xFFC03028),
  Poison() => const Color(0xFFA040A0),
  Ground() => const Color(0xFFE0C068),
  Flying() => const Color(0xFFA890F0),
  Psychic() => const Color(0xFFF85888),
  Bug() => const Color(0xFFA8B820),
  Rock() => const Color(0xFFB8A038),
  Ghost() => const Color(0xFF705898),
  Dragon() => const Color(0xFF7038F8),
  Dark() => const Color(0xFF705848),
  Steel() => const Color(0xFFB8B8D0),
  Fairy() => const Color(0xFFEE99AC),
};
