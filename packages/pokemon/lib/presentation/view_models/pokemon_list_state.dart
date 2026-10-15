import 'package:core/core.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/type.dart';

sealed class PokemonListState {
  const PokemonListState();
}

final class PokemonListInitial extends PokemonListState {
  const PokemonListInitial();
}

final class PokemonListLoading extends PokemonListState {
  const PokemonListLoading();
}

final class PokemonListSuccess extends PokemonListState {
  const PokemonListSuccess({
    required this.pokemon,
    required this.hasNext,
    required this.fetchOffset,
    this.selectedType,
    this.searchQuery = '',
    this.isReloading = false,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final List<Pokemon> pokemon;
  final bool hasNext;
  final int fetchOffset;
  final Type? selectedType;
  final String searchQuery;
  final bool isReloading;
  final bool isLoadingMore;
  final Failure? loadMoreFailure;
}

final class PokemonListFailure extends PokemonListState {
  const PokemonListFailure(this.failure);

  final Failure failure;
}
