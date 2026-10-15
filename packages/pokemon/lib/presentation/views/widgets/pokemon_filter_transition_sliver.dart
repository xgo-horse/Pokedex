import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_fade.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_tile.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_tile_fade_in.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_tile_skeleton.dart';

enum _GridContent { pokemon, skeleton, empty }

class PokemonFilterTransitionSliver extends StatefulWidget {
  const PokemonFilterTransitionSliver({
    super.key,
    required this.pokemon,
    required this.isReloading,
    required this.selectedType,
    required this.searchQuery,
    required this.crossAxisCount,
  });

  final List<Pokemon> pokemon;
  final bool isReloading;
  final Type? selectedType;
  final String searchQuery;
  final int crossAxisCount;

  @override
  State<PokemonFilterTransitionSliver> createState() =>
      _PokemonFilterTransitionSliverState();
}

class _PokemonFilterTransitionSliverState
    extends State<PokemonFilterTransitionSliver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  late _GridContent _content;
  List<Pokemon> _displayPokemon = const [];
  int _tileFadeStartIndex = 0;
  int _reloadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kPokemonGridFadeDuration,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: kPokemonGridFadeCurve,
    );
    _displayPokemon = widget.pokemon;

    if (widget.isReloading) {
      _content = _GridContent.skeleton;
      _controller.forward();
    } else {
      _content = widget.pokemon.isEmpty
          ? _GridContent.empty
          : _GridContent.pokemon;
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(PokemonFilterTransitionSliver oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isReloading && !oldWidget.isReloading) {
      _startReload();
      return;
    }

    if (!widget.isReloading && oldWidget.isReloading) {
      _finishReload();
      return;
    }

    if (widget.isReloading &&
        oldWidget.isReloading &&
        (widget.selectedType != oldWidget.selectedType ||
            widget.searchQuery != oldWidget.searchQuery)) {
      _reloadGeneration++;
      _controller.stop();
      _displayPokemon = widget.pokemon;
      if (_content != _GridContent.skeleton) {
        setState(() => _content = _GridContent.skeleton);
        _controller.value = 1;
      }
      return;
    }

    if (!widget.isReloading && !oldWidget.isReloading) {
      if (widget.selectedType == oldWidget.selectedType &&
          widget.pokemon.length > oldWidget.pokemon.length) {
        // On web, skip per-tile entrance animations for appended pages.
        _tileFadeStartIndex = kIsWeb
            ? widget.pokemon.length
            : oldWidget.pokemon.length;
        _displayPokemon = widget.pokemon;
        return;
      }

      if (widget.selectedType != oldWidget.selectedType ||
          widget.searchQuery != oldWidget.searchQuery ||
          widget.pokemon != oldWidget.pokemon) {
        _applyResult();
      }
    }
  }

  void _startReload() {
    final generation = ++_reloadGeneration;
    _controller.reverse().whenComplete(() {
      if (!mounted || generation != _reloadGeneration || !widget.isReloading) {
        return;
      }
      setState(() => _content = _GridContent.skeleton);
      _controller.value = 1;
    });
  }

  void _finishReload() {
    _reloadGeneration++;
    _displayPokemon = widget.pokemon;
    final nextContent = widget.pokemon.isEmpty
        ? _GridContent.empty
        : _GridContent.pokemon;

    setState(() {
      _content = nextContent;
      _tileFadeStartIndex = _displayPokemon.length;
    });
    _controller
      ..value = 0
      ..forward();
  }

  /// Applies new filter results when reload transitions were coalesced into
  /// a single frame (e.g. cache hits), so [_finishReload] never ran.
  void _applyResult() {
    _reloadGeneration++;
    _controller.stop();
    _displayPokemon = widget.pokemon;
    final nextContent = widget.pokemon.isEmpty
        ? _GridContent.empty
        : _GridContent.pokemon;

    setState(() {
      _content = nextContent;
      _tileFadeStartIndex = _displayPokemon.length;
    });
    _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build grid/skeleton/empty once per State rebuild. AnimatedBuilder's
    // `child` is reused across opacity ticks so tiles are not reconstructed
    // every animation frame.
    final sliver = switch (_content) {
      _GridContent.skeleton => _skeletonGrid(),
      _GridContent.empty => _emptyMessage(context),
      _GridContent.pokemon => _pokemonGrid(),
    };

    return AnimatedBuilder(
      animation: _opacity,
      child: sliver,
      builder: (context, child) {
        return SliverOpacity(opacity: _opacity.value, sliver: child!);
      },
    );
  }

  Widget _skeletonGrid() {
    final skeletonCount = widget.crossAxisCount * 4;
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          childAspectRatio: 0.72,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const PokemonGridTileSkeleton(),
          childCount: skeletonCount,
        ),
      ),
    );
  }

  Widget _pokemonGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          childAspectRatio: 0.72,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = _displayPokemon[index];
          final shouldFadeIn = !kIsWeb && index >= _tileFadeStartIndex;
          if (shouldFadeIn) {
            return PokemonGridTileFadeIn(
              key: ValueKey(entry.id),
              child: PokemonGridTile(pokemon: entry),
            );
          }
          return PokemonGridTile(key: ValueKey(entry.id), pokemon: entry);
        }, childCount: _displayPokemon.length),
      ),
    );
  }

  Widget _emptyMessage(BuildContext context) {
    final message = widget.searchQuery.isNotEmpty
        ? context.pokemonStrings.searchEmptyMessage
        : context.pokemonStrings.filterEmptyMessage;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(
          message,
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}
