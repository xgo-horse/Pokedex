import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/use_cases/load_pokemon_list.dart';
import 'package:pokemon/presentation/commands/pokemon_list_command.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_state.dart';

const _pageSize = 30;

class PokemonListCubit extends Cubit<PokemonListState> {
  PokemonListCubit(this._loadPokemonList) : super(const PokemonListInitial());

  final LoadPokemonList _loadPokemonList;
  int _loadGeneration = 0;

  Future<void> execute(PokemonListCommand command) async => switch (command) {
    LoadPokemonListCommand() => _load(),
    RefreshPokemonListCommand() => _load(
      preserveType: true,
      preserveSearchQuery: true,
      forceRefresh: true,
    ),
    FilterPokemonListCommand(:final type) => _load(
      type: type,
      preserveSearchQuery: true,
    ),
    SearchPokemonListCommand(:final query) => _load(
      preserveType: true,
      nameQuery: query,
    ),
    LoadMorePokemonListCommand() => _loadMore(),
  };

  Type? get _selectedType => switch (state) {
    PokemonListSuccess(:final selectedType) => selectedType,
    _ => null,
  };

  String get _searchQuery => switch (state) {
    PokemonListSuccess(:final searchQuery) => searchQuery,
    _ => '',
  };

  /// Completes after a refresh/load cycle finishes (leaves reloading state).
  Future<void> waitForIdle() async {
    if (state case PokemonListSuccess(isReloading: false)) {
      await stream.firstWhere(
        (state) => switch (state) {
          PokemonListSuccess(isReloading: true) => true,
          _ => false,
        },
      );
    }
    await stream.firstWhere(
      (state) => switch (state) {
        PokemonListSuccess(isReloading: true) => false,
        _ => true,
      },
    );
  }

  Future<void> _load({
    Type? type,
    String? nameQuery,
    bool preserveType = false,
    bool preserveSearchQuery = false,
    bool forceRefresh = false,
  }) async {
    final filterType = preserveType ? (type ?? _selectedType) : type;
    final effectiveSearchQuery = preserveSearchQuery
        ? (nameQuery ?? _searchQuery)
        : (nameQuery ?? '');
    final generation = ++_loadGeneration;
    final previousPokemon = switch (state) {
      PokemonListSuccess(:final pokemon) => pokemon,
      _ => const <Pokemon>[],
    };
    emit(
      PokemonListSuccess(
        pokemon: previousPokemon,
        hasNext: false,
        fetchOffset: 0,
        selectedType: filterType,
        searchQuery: effectiveSearchQuery,
        isReloading: true,
      ),
    );
    final result = await _loadPokemonList(
      limit: _pageSize,
      offset: 0,
      type: filterType,
      nameQuery: effectiveSearchQuery.isEmpty ? null : effectiveSearchQuery,
      forceRefresh: forceRefresh,
    );
    if (generation != _loadGeneration) {
      return;
    }
    emit(switch (result) {
      Right(:final value) => PokemonListSuccess(
        pokemon: value.pokemon,
        hasNext: value.hasNext,
        fetchOffset: _pageSize,
        selectedType: filterType,
        searchQuery: effectiveSearchQuery,
      ),
      Left(:final value) => PokemonListFailure(value),
    });
  }

  Future<void> _loadMore() async {
    final current = state;
    if (current is! PokemonListSuccess ||
        current.isReloading ||
        !current.hasNext ||
        current.isLoadingMore) {
      return;
    }

    final generation = _loadGeneration;
    final selectedType = current.selectedType;
    final searchQuery = current.searchQuery;

    emit(
      PokemonListSuccess(
        pokemon: current.pokemon,
        hasNext: current.hasNext,
        fetchOffset: current.fetchOffset,
        selectedType: current.selectedType,
        searchQuery: current.searchQuery,
        isLoadingMore: true,
      ),
    );

    final result = await _loadPokemonList(
      limit: _pageSize,
      offset: current.fetchOffset,
      type: current.selectedType,
      nameQuery: searchQuery.isEmpty ? null : searchQuery,
    );

    if (generation != _loadGeneration) {
      return;
    }

    final latest = state;
    if (latest is! PokemonListSuccess ||
        latest.selectedType != selectedType ||
        latest.searchQuery != searchQuery) {
      return;
    }

    switch (result) {
      case Right(:final value):
        emit(
          PokemonListSuccess(
            pokemon: [...current.pokemon, ...value.pokemon],
            hasNext: value.hasNext,
            fetchOffset: current.fetchOffset + _pageSize,
            selectedType: current.selectedType,
            searchQuery: current.searchQuery,
          ),
        );
      case Left(:final value):
        if (current.pokemon.isEmpty) {
          emit(PokemonListFailure(value));
        } else {
          emit(
            PokemonListSuccess(
              pokemon: current.pokemon,
              hasNext: current.hasNext,
              fetchOffset: current.fetchOffset,
              selectedType: current.selectedType,
              searchQuery: current.searchQuery,
              loadMoreFailure: value,
            ),
          );
        }
    }
  }
}
