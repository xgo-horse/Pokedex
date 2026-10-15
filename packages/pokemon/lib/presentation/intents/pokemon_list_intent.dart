import 'package:flutter/widgets.dart';
import 'package:pokemon/domain/models/type.dart';

final class LoadPokemonListIntent extends Intent {
  const LoadPokemonListIntent();
}

final class RefreshPokemonListIntent extends Intent {
  const RefreshPokemonListIntent();
}

final class LoadMorePokemonListIntent extends Intent {
  const LoadMorePokemonListIntent();
}

final class FilterPokemonListIntent extends Intent {
  const FilterPokemonListIntent(this.type);

  final Type? type;
}

final class SearchPokemonListIntent extends Intent {
  const SearchPokemonListIntent(this.query);

  final String query;
}

final class CyclePokemonFilterIntent extends Intent {
  const CyclePokemonFilterIntent(this.delta);

  /// Typically `-1` (previous) or `1` (next).
  final int delta;
}

final class OpenPokemonDetailIntent extends Intent {
  const OpenPokemonDetailIntent({required this.id, required this.name});

  final int id;
  final String name;
}
