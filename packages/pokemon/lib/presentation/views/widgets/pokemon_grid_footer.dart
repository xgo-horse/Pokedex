import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';

class PokemonGridFooter extends StatelessWidget {
  const PokemonGridFooter({
    super.key,
    required this.isLoadingMore,
    required this.loadMoreFailure,
  });

  final bool isLoadingMore;
  final Failure? loadMoreFailure;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (loadMoreFailure != null) {
      final l10n = context.pokemonStrings;
      final secondaryLabel = CupertinoDynamicColor.resolve(
        CupertinoColors.secondaryLabel,
        context,
      );
      final messageStyle = CupertinoTheme.of(
        context,
      ).textTheme.textStyle.copyWith(color: secondaryLabel, fontSize: 13);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.failureMessage(loadMoreFailure!),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: messageStyle,
            ),
            const SizedBox(height: 8),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: () =>
                  Actions.invoke(context, const LoadMorePokemonListIntent()),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

int crossAxisCountForWidth(double width) {
  if (width >= 1200) {
    return 6;
  }
  if (width >= 900) {
    return 5;
  }
  if (width >= 600) {
    return 4;
  }
  return 3;
}
