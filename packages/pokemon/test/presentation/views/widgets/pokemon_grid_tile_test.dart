import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_tile.dart';

import '../../../test_helpers.dart';

void main() {
  testWidgets('invokes OpenPokemonDetailIntent when tapped', (tester) async {
    int? openedId;
    String? openedName;

    await tester.pumpWidget(
      testApp(
        home: Actions(
          actions: {
            OpenPokemonDetailIntent: CallbackAction<OpenPokemonDetailIntent>(
              onInvoke: (intent) {
                openedId = intent.id;
                openedName = intent.name;
                return null;
              },
            ),
          },
          child: Center(
            child: SizedBox(
              width: 160,
              height: 220,
              child: PokemonGridTile(
                pokemon: testPokemon(id: 25, name: 'pikachu'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PokemonGridTile));
    await tester.pump();

    expect(openedId, 25);
    expect(openedName, 'pikachu');
  });

  testWidgets('matches golden file', (tester) async {
    await tester.pumpWidget(
      testApp(
        home: Center(
          child: SizedBox(
            width: 160,
            height: 220,
            child: PokemonGridTile(
              pokemon: testPokemon(id: 1, name: 'bulbasaur'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(PokemonGridTile),
      matchesGoldenFile('goldens/pokemon_grid_tile.png'),
    );
  });
}
