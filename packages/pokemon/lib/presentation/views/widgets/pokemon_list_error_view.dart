import 'package:flutter/cupertino.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';

class PokemonListErrorView extends StatelessWidget {
  const PokemonListErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.pokemonStrings;
    final secondaryLabel = CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    );
    final messageStyle = CupertinoTheme.of(
      context,
    ).textTheme.textStyle.copyWith(color: secondaryLabel);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: secondaryLabel,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: messageStyle),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: () =>
                  Actions.invoke(context, const RefreshPokemonListIntent()),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
