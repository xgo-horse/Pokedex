import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';
import 'package:pokemon/presentation/theme/pokemon_type_colors.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_type_filter_bar.dart';

import '../../../test_helpers.dart';

class _Harness extends StatefulWidget {
  const _Harness({required this.types});

  final List<Type> types;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  Type? selectedType;
  final invokedTypes = <Type?>[];

  @override
  Widget build(BuildContext context) {
    return testApp(
      home: Actions(
        actions: {
          FilterPokemonListIntent: CallbackAction<FilterPokemonListIntent>(
            onInvoke: (intent) {
              invokedTypes.add(intent.type);
              setState(() => selectedType = intent.type);
              return null;
            },
          ),
        },
        child: Center(
          child: SizedBox(
            width: 320,
            child: PokemonTypeFilterBar(
              types: widget.types,
              selectedType: selectedType,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionHarness extends StatefulWidget {
  const _SelectionHarness({
    super.key,
    required this.types,
    required this.selectedType,
  });

  final List<Type> types;
  final Type? selectedType;

  @override
  State<_SelectionHarness> createState() => _SelectionHarnessState();
}

class _SelectionHarnessState extends State<_SelectionHarness> {
  late Type? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedType;
  }

  void select(Type? type) => setState(() => selectedType = type);

  @override
  Widget build(BuildContext context) {
    return testApp(
      home: Center(
        child: SizedBox(
          width: 200,
          child: PokemonTypeFilterBar(
            types: widget.types,
            selectedType: selectedType,
          ),
        ),
      ),
    );
  }
}

void main() {
  final types = [Fire(), Water(), Grass()];

  testWidgets('shows All and keeps it visible', (tester) async {
    final l10n = await englishLocalizations();
    await tester.pumpWidget(_Harness(types: types));
    await tester.pumpAndSettle();

    expect(find.text(l10n.filterAll), findsOneWidget);
    expect(find.text(l10n.pokemonType(Fire())), findsOneWidget);
    expect(find.text(l10n.pokemonType(Water())), findsOneWidget);
    expect(find.text(l10n.pokemonType(Grass())), findsOneWidget);
  });

  testWidgets('selects a type with solid type color styling', (tester) async {
    final l10n = await englishLocalizations();
    await tester.pumpWidget(_Harness(types: types));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.pokemonType(Fire())));
    await tester.pumpAndSettle();

    final harnessState = tester.state<_HarnessState>(find.byType(_Harness));
    expect(harnessState.selectedType, isA<Fire>());
    expect(harnessState.invokedTypes, [isA<Fire>()]);

    final fireButton = tester.widget<CupertinoButton>(
      find.ancestor(
        of: find.text(l10n.pokemonType(Fire())),
        matching: find.byType(CupertinoButton),
      ),
    );
    final decoration =
        ((fireButton.child as DecoratedBox).decoration as BoxDecoration);
    expect(decoration.color, colorForType(Fire()));
    expect(decoration.border, isNull);
  });

  testWidgets('tapping selected type clears to All', (tester) async {
    final l10n = await englishLocalizations();
    await tester.pumpWidget(_Harness(types: types));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.pokemonType(Water())));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.pokemonType(Water())));
    await tester.pumpAndSettle();

    final harnessState = tester.state<_HarnessState>(find.byType(_Harness));
    expect(harnessState.selectedType, isNull);
    expect(harnessState.invokedTypes.length, 2);
    expect(harnessState.invokedTypes[0], isA<Water>());
    expect(harnessState.invokedTypes[1], isNull);
  });

  testWidgets('unselected type chips use a subtle type-color hint', (
    tester,
  ) async {
    final l10n = await englishLocalizations();
    await tester.pumpWidget(_Harness(types: types));
    await tester.pumpAndSettle();

    final grassButton = tester.widget<CupertinoButton>(
      find.ancestor(
        of: find.text(l10n.pokemonType(Grass())),
        matching: find.byType(CupertinoButton),
      ),
    );
    final decoration =
        ((grassButton.child as DecoratedBox).decoration as BoxDecoration);
    final typeColor = colorForType(Grass());

    expect(decoration.color, typeColor.withValues(alpha: 0.18));
    expect(decoration.border?.top.color, typeColor.withValues(alpha: 0.35));
  });

  testWidgets('shows empty-state copy when filter has no matches', (
    tester,
  ) async {
    final l10n = await englishLocalizations();
    await tester.pumpWidget(
      testApp(
        home: PokemonTypeFilterBar(
          types: types,
          selectedType: Fire(),
          isEmpty: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.filterEmptyMessage), findsOneWidget);
  });

  testWidgets('hides empty-state copy when All is selected', (tester) async {
    final l10n = await englishLocalizations();
    await tester.pumpWidget(
      testApp(
        home: PokemonTypeFilterBar(
          types: types,
          selectedType: null,
          isEmpty: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.filterEmptyMessage), findsNothing);
  });

  testWidgets('scrolls back to All when selection wraps from last type', (
    tester,
  ) async {
    final manyTypes = [
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
    ];
    final harnessKey = GlobalKey<_SelectionHarnessState>();

    await tester.pumpWidget(
      _SelectionHarness(
        key: harnessKey,
        types: manyTypes,
        selectedType: Psychic(),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    final controller = scrollable.widget.controller!;
    expect(controller.offset, greaterThan(0));

    harnessKey.currentState!.select(null);
    await tester.pumpAndSettle();

    expect(controller.offset, lessThan(1));
  });

  testWidgets('scrolls forward to last type when selection wraps from All', (
    tester,
  ) async {
    final manyTypes = [
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
    ];
    final harnessKey = GlobalKey<_SelectionHarnessState>();

    await tester.pumpWidget(
      _SelectionHarness(key: harnessKey, types: manyTypes, selectedType: null),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    final controller = scrollable.widget.controller!;
    expect(controller.offset, lessThan(1));

    harnessKey.currentState!.select(Psychic());
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
  });
}
