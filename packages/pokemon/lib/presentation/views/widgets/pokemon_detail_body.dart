import 'package:flutter/cupertino.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_type_chip.dart';

class PokemonDetailBody extends StatelessWidget {
  const PokemonDetailBody({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final secondaryLabel = CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    );
    final backgroundColor = CupertinoDynamicColor.resolve(
      CupertinoColors.secondarySystemGroupedBackground,
      context,
    );
    final subtitleStyle = CupertinoTheme.of(
      context,
    ).textTheme.textStyle.copyWith(fontSize: 15, color: secondaryLabel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                pokemon.imageUrl.toString(),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(CupertinoIcons.photo, size: 64, color: secondaryLabel),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('#${pokemon.id.toString().padLeft(3, '0')}', style: subtitleStyle),
        if (pokemon.types.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in pokemon.types) PokemonTypeChip(type: type),
            ],
          ),
        ],
      ],
    );
  }
}
