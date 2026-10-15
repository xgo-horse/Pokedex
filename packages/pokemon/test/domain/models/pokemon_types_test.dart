import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/pokemon_types.dart';
import 'package:pokemon/domain/models/type.dart';

void main() {
  group('cyclePokemonTypeFilter', () {
    final types = [Fire(), Water(), Grass()];

    test('moves from All to first type on next', () {
      expect(cyclePokemonTypeFilter(null, delta: 1, types: types), isA<Fire>());
    });

    test('moves from first type to All on previous', () {
      expect(cyclePokemonTypeFilter(Fire(), delta: -1, types: types), isNull);
    });

    test('wraps from last type to All on next', () {
      expect(cyclePokemonTypeFilter(Grass(), delta: 1, types: types), isNull);
    });

    test('wraps from All to last type on previous', () {
      expect(
        cyclePokemonTypeFilter(null, delta: -1, types: types),
        isA<Grass>(),
      );
    });

    test('advances between types', () {
      expect(
        cyclePokemonTypeFilter(Fire(), delta: 1, types: types),
        isA<Water>(),
      );
    });
  });
}
