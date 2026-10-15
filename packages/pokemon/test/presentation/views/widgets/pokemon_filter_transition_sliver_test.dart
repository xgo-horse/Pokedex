import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_filter_transition_sliver.dart';

import '../../../test_helpers.dart';

class _Harness extends StatefulWidget {
  const _Harness({
    super.key,
    required this.pokemon,
    required this.isReloading,
    required this.selectedType,
  });

  final List<Pokemon> pokemon;
  final bool isReloading;
  final Type? selectedType;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late List<Pokemon> _pokemon;
  late bool _isReloading;
  late Type? _selectedType;

  @override
  void initState() {
    super.initState();
    _pokemon = widget.pokemon;
    _isReloading = widget.isReloading;
    _selectedType = widget.selectedType;
  }

  void showFilterResult({
    required List<Pokemon> pokemon,
    required Type? selectedType,
  }) {
    setState(() {
      _pokemon = pokemon;
      _isReloading = false;
      _selectedType = selectedType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return testApp(
      home: CustomScrollView(
        slivers: [
          PokemonFilterTransitionSliver(
            pokemon: _pokemon,
            isReloading: _isReloading,
            selectedType: _selectedType,
            searchQuery: '',
            crossAxisCount: 2,
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets(
    'updates displayed pokemon when filter changes without reloading frame',
    (tester) async {
      final waterPokemon = [
        testPokemon(id: 7, name: 'squirtle', types: [Water()]),
      ];
      final grassPokemon = [
        testPokemon(id: 1, name: 'bulbasaur', types: [Grass()]),
      ];

      final harnessKey = GlobalKey<_HarnessState>();
      await tester.pumpWidget(
        _Harness(
          key: harnessKey,
          pokemon: waterPokemon,
          isReloading: false,
          selectedType: Water(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Squirtle'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsNothing);

      harnessKey.currentState!.showFilterResult(
        pokemon: grassPokemon,
        selectedType: Grass(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Squirtle'), findsNothing);
    },
  );
}
