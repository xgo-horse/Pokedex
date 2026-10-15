import 'package:flutter/cupertino.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_type_filter_bar.dart';

/// Type filter scope bar below the search navigation bar.
///
/// Uses [SliverToBoxAdapter] rather than a pinned persistent header because
/// [CupertinoSliverNavigationBar.search] already owns a pinned sliver delegate;
/// stacking a second pinned header triggers invalid [SliverGeometry] overlap.
class PokemonTypeFilterHeader extends StatelessWidget {
  const PokemonTypeFilterHeader({
    super.key,
    required this.types,
    required this.selectedType,
    required this.isEmpty,
  });

  final List<Type> types;
  final Type? selectedType;
  final bool isEmpty;

  static const _height = 48.0;
  static const _emptyHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final height = isEmpty && selectedType != null ? _emptyHeight : _height;

    return SliverToBoxAdapter(
      child: ColoredBox(
        color: CupertinoDynamicColor.resolve(
          CupertinoTheme.of(context).barBackgroundColor,
          context,
        ),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: PokemonTypeFilterBar(
              types: types,
              selectedType: selectedType,
              isEmpty: isEmpty,
            ),
          ),
        ),
      ),
    );
  }
}
