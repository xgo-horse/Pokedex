import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';
import 'package:pokemon/presentation/theme/pokemon_type_colors.dart';

class PokemonTypeFilterBar extends StatefulWidget {
  const PokemonTypeFilterBar({
    super.key,
    required this.types,
    required this.selectedType,
    this.isEmpty = false,
  });

  final List<Type> types;
  final Type? selectedType;

  /// When true and a type filter is active, shows empty-state copy under the
  /// chips.
  final bool isEmpty;

  @override
  State<PokemonTypeFilterBar> createState() => _PokemonTypeFilterBarState();
}

class _PokemonTypeFilterBarState extends State<PokemonTypeFilterBar> {
  static const _fadeWidth = 24.0;
  static const _chipRowHeight = 36.0;

  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _chipKeys = {};

  var _showLeftFade = false;
  var _showRightFade = false;

  bool get _showEmptyMessage => widget.isEmpty && widget.selectedType != null;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFades);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFades();
      _ensureSelectedVisible(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant PokemonTypeFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectionChanged =
        oldWidget.selectedType?.name != widget.selectedType?.name;
    final layoutChanged = oldWidget.isEmpty != widget.isEmpty;
    if (selectionChanged || layoutChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _ensureSelectedVisible(animate: selectionChanged);
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateFades)
      ..dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String id) => _chipKeys.putIfAbsent(id, GlobalKey.new);

  void _updateFades() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final showLeft = position.pixels > 0.5;
    final showRight = position.pixels < position.maxScrollExtent - 0.5;
    if (showLeft == _showLeftFade && showRight == _showRightFade) {
      return;
    }

    setState(() {
      _showLeftFade = showLeft;
      _showRightFade = showRight;
    });
  }

  void _ensureSelectedVisible({bool animate = true}) {
    if (!_scrollController.hasClients) {
      return;
    }

    final key = _keyFor(_chipId(widget.selectedType));
    final chipContext = key.currentContext;
    if (chipContext == null) {
      return;
    }

    final chipBox = chipContext.findRenderObject();
    if (chipBox is! RenderBox || !chipBox.attached || !chipBox.hasSize) {
      return;
    }

    final viewport = RenderAbstractViewport.of(chipBox);
    final target = viewport
        .getOffsetToReveal(chipBox, 0.5)
        .offset
        .clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        )
        .toDouble();

    if ((target - _scrollController.offset).abs() < 0.5) {
      _updateFades();
      return;
    }

    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
      _updateFades();
    }
  }

  String _chipId(Type? type) => type?.name ?? 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = context.pokemonStrings;
    final fadeColor = CupertinoDynamicColor.resolve(
      CupertinoTheme.of(context).barBackgroundColor,
      context,
    );
    final emptyStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
      fontSize: 12,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _chipRowHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _FilterChip(
                      key: _keyFor('all'),
                      label: l10n.filterAll,
                      isSelected: widget.selectedType == null,
                      onPressed: () => Actions.invoke(
                        context,
                        const FilterPokemonListIntent(null),
                      ),
                    ),
                    for (final type in widget.types) ...[
                      const SizedBox(width: 8),
                      _FilterChip(
                        key: _keyFor(type.name),
                        label: l10n.pokemonType(type),
                        isSelected: widget.selectedType?.name == type.name,
                        type: type,
                        onPressed: () {
                          final clear = widget.selectedType?.name == type.name;
                          Actions.invoke(
                            context,
                            FilterPokemonListIntent(clear ? null : type),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              if (_showLeftFade)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _fadeWidth,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [fadeColor, fadeColor.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showRightFade)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: _fadeWidth,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [fadeColor.withValues(alpha: 0), fadeColor],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_showEmptyMessage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              l10n.filterEmptyMessage,
              style: emptyStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.type,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Type? type;

  @override
  Widget build(BuildContext context) {
    final labelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );

    late final Color backgroundColor;
    late final Color textColor;
    Color? borderColor;

    if (type != null) {
      final typeColor = colorForType(type!);
      if (isSelected) {
        backgroundColor = typeColor;
        textColor = CupertinoColors.white;
      } else {
        backgroundColor = typeColor.withValues(alpha: 0.18);
        borderColor = typeColor.withValues(alpha: 0.35);
        textColor = labelColor;
      }
    } else if (isSelected) {
      backgroundColor = CupertinoDynamicColor.resolve(
        CupertinoColors.activeBlue,
        context,
      );
      textColor = CupertinoColors.white;
    } else {
      backgroundColor = CupertinoDynamicColor.resolve(
        CupertinoColors.tertiarySystemFill,
        context,
      );
      textColor = labelColor;
    }

    final textStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: textColor,
    );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: borderColor == null
              ? null
              : Border.all(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(label, style: textStyle),
        ),
      ),
    );
  }
}
