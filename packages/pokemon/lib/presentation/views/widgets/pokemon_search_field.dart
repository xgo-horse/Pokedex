import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';

class PokemonSearchField extends StatefulWidget {
  const PokemonSearchField({
    super.key,
    required this.searchQuery,
    this.debounceDuration = const Duration(milliseconds: 350),
  });

  final String searchQuery;
  final Duration debounceDuration;

  @override
  State<PokemonSearchField> createState() => _PokemonSearchFieldState();
}

class _PokemonSearchFieldState extends State<PokemonSearchField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(PokemonSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (!mounted) {
        return;
      }
      Actions.invoke(context, SearchPokemonListIntent(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      controller: _controller,
      placeholder: context.pokemonStrings.searchPlaceholder,
      onChanged: _onChanged,
    );
  }
}
