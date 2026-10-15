import 'package:pokemon/domain/models/type.dart';

final allPokemonTypes = <Type>[
  Normal(),
  Fire(),
  Water(),
  Grass(),
  Electric(),
  Ice(),
  Fighting(),
  Poison(),
  Ground(),
  Flying(),
  Psychic(),
  Bug(),
  Rock(),
  Ghost(),
  Dragon(),
  Dark(),
  Steel(),
  Fairy(),
];

/// Cycles through All (`null`) and [types]. [delta] is typically `-1` or `1`.
Type? cyclePokemonTypeFilter(
  Type? selected, {
  required int delta,
  List<Type>? types,
}) {
  final list = types ?? allPokemonTypes;
  if (list.isEmpty || delta == 0) {
    return selected;
  }

  final count = list.length + 1;
  final selectedIndex = selected == null
      ? -1
      : list.indexWhere((type) => type.name == selected.name);
  final currentPos = selectedIndex + 1;
  final nextPos = (currentPos + delta) % count;
  final normalizedPos = nextPos < 0 ? nextPos + count : nextPos;
  return normalizedPos == 0 ? null : list[normalizedPos - 1];
}
