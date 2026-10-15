import 'package:flutter/cupertino.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';
import 'package:pokemon/presentation/theme/pokemon_type_colors.dart';

class PokemonTypeChip extends StatelessWidget {
  const PokemonTypeChip({super.key, required this.type});

  final Type type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.pokemonStrings;
    final backgroundColor = colorForType(type);
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: CupertinoColors.white,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.pokemonType(type),
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
