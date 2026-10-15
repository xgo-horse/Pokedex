import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_tile_image.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_type_chip.dart';

class PokemonGridTile extends StatelessWidget {
  const PokemonGridTile({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = CupertinoDynamicColor.resolve(
      CupertinoColors.secondarySystemGroupedBackground,
      context,
    );
    final borderColor = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );
    final secondaryLabel = CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    );
    final placeholderColor = CupertinoDynamicColor.resolve(
      CupertinoColors.tertiarySystemFill,
      context,
    );
    final nameStyle = CupertinoTheme.of(
      context,
    ).textTheme.textStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 13);
    final idStyle = CupertinoTheme.of(
      context,
    ).textTheme.textStyle.copyWith(fontSize: 11, color: secondaryLabel);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => Actions.invoke(
        context,
        OpenPokemonDetailIntent(id: pokemon.id, name: pokemon.name),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final dpr = MediaQuery.devicePixelRatioOf(context);
                      // Decode near display size to avoid full-res sprite cost.
                      final cacheWidth = (constraints.maxWidth * dpr)
                          .round()
                          .clamp(1, 1024);
                      final cacheHeight = (constraints.maxHeight * dpr)
                          .round()
                          .clamp(1, 1024);
                      return Image.network(
                        pokemon.imageUrl.toString(),
                        fit: BoxFit.contain,
                        cacheWidth: cacheWidth,
                        cacheHeight: cacheHeight,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                // Skip per-image fade controllers on web.
                                if (kIsWeb) {
                                  return child;
                                }
                                return PokemonGridTileImageFade(child: child);
                              }
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: placeholderColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: CupertinoActivityIndicator(radius: 10),
                                ),
                              );
                            },
                        errorBuilder: (_, _, _) => Icon(
                          CupertinoIcons.photo,
                          size: 32,
                          color: secondaryLabel,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: idStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _capitalize(pokemon.name),
                      style: nameStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pokemon.types.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final type in pokemon.types.take(2))
                            PokemonTypeChip(type: type),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
