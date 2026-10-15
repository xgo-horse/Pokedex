import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_types.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/presentation/actions/pokemon_list_action.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_cubit.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_state.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_footer.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_filter_transition_sliver.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_list_error_view.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_search_field.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_type_filter_header.dart';

class PokemonListScreen extends StatelessWidget {
  const PokemonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        LoadPokemonListIntent: LoadPokemonListAction(),
        RefreshPokemonListIntent: RefreshPokemonListAction(),
        LoadMorePokemonListIntent: LoadMorePokemonListAction(),
        FilterPokemonListIntent: FilterPokemonListAction(),
        SearchPokemonListIntent: SearchPokemonListAction(),
        CyclePokemonFilterIntent: CyclePokemonFilterAction(),
        OpenPokemonDetailIntent: OpenPokemonDetailAction(),
      },
      child: const _PokemonListKeyboardScope(
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: _PokemonListBody(),
        ),
      ),
    );
  }
}

class _PokemonListKeyboardScope extends StatefulWidget {
  const _PokemonListKeyboardScope({required this.child});

  final Widget child;

  @override
  State<_PokemonListKeyboardScope> createState() =>
      _PokemonListKeyboardScopeState();
}

class _PokemonListKeyboardScopeState extends State<_PokemonListKeyboardScope> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }
    if (HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isAltPressed) {
      return false;
    }
    if (!mounted) {
      return false;
    }

    final Intent? intent = switch (event.logicalKey) {
      LogicalKeyboardKey.keyR => const RefreshPokemonListIntent(),
      LogicalKeyboardKey.digit0 => const FilterPokemonListIntent(null),
      LogicalKeyboardKey.bracketLeft => const CyclePokemonFilterIntent(-1),
      LogicalKeyboardKey.bracketRight => const CyclePokemonFilterIntent(1),
      _ => null,
    };
    if (intent == null) {
      return false;
    }

    Actions.invoke(context, intent);
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _PokemonListBody extends StatefulWidget {
  const _PokemonListBody();

  @override
  State<_PokemonListBody> createState() => _PokemonListBodyState();
}

class _PokemonListBodyState extends State<_PokemonListBody> {
  late final ScrollController _scrollController;

  /// Prevents Intent/Cubit spam while a load-more is already in flight.
  var _loadMoreRequested = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter >= 200) {
      return;
    }

    final state = context.read<PokemonListCubit>().state;
    final canLoadMore = switch (state) {
      PokemonListSuccess(
        isReloading: false,
        hasNext: true,
        isLoadingMore: false,
      ) =>
        !_loadMoreRequested,
      _ => false,
    };
    if (!canLoadMore) {
      return;
    }

    _loadMoreRequested = true;
    Actions.invoke(context, const LoadMorePokemonListIntent());
  }

  void _onLoadMoreSettled() {
    if (!_loadMoreRequested) {
      return;
    }
    _loadMoreRequested = false;
    // Still near the bottom after a page append — request the next page once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onScroll();
      }
    });
  }

  Future<void> _onRefresh() async {
    final cubit = context.read<PokemonListCubit>();
    Actions.invoke(context, const RefreshPokemonListIntent());
    await cubit.waitForIdle();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PokemonListCubit, PokemonListState>(
      listenWhen: (previous, current) {
        final reloadStarted = switch (current) {
          PokemonListSuccess(isReloading: true) => true,
          _ => false,
        };
        final loadMoreSettled =
            previous is PokemonListSuccess &&
            previous.isLoadingMore &&
            current is PokemonListSuccess &&
            !current.isLoadingMore;
        return reloadStarted || loadMoreSettled;
      },
      listener: (context, state) {
        if (state case PokemonListSuccess(isReloading: true)) {
          _loadMoreRequested = false;
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
          return;
        }
        if (state case PokemonListSuccess(isLoadingMore: false)) {
          _onLoadMoreSettled();
        }
      },
      // Outer shell only switches failure ↔ content. Load-more updates go
      // through nested BlocSelectors so nav/filter chrome is not rebuilt.
      buildWhen: (previous, current) {
        final previousFailed = previous is PokemonListFailure;
        final currentFailed = current is PokemonListFailure;
        return previousFailed != currentFailed;
      },
      builder: (context, state) => switch (state) {
        PokemonListFailure(:final failure) => CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text(context.pokemonStrings.appTitle),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: PokemonListErrorView(
                message: context.pokemonStrings.failureMessage(failure),
              ),
            ),
          ],
        ),
        _ => _PokemonGrid(
          scrollController: _scrollController,
          onRefresh: _onRefresh,
        ),
      },
    );
  }
}

/// Filter / nav chrome inputs. Stable across load-more emits.
typedef _ChromeSlice = ({
  Type? selectedType,
  String searchQuery,
  bool isReloading,
  bool isEmpty,
});

/// Grid inputs. Changes when pokemon list or reload/filter/search changes.
typedef _GridSlice = ({
  List<Pokemon> pokemon,
  bool isReloading,
  Type? selectedType,
  String searchQuery,
});

/// Footer inputs. Changes for load-more spinner / errors.
typedef _FooterSlice = ({
  bool showFooter,
  bool isLoadingMore,
  Failure? loadMoreFailure,
});

_ChromeSlice _chromeSlice(PokemonListState state) => switch (state) {
  PokemonListSuccess(
    :final selectedType,
    :final searchQuery,
    :final isReloading,
    :final pokemon,
  ) =>
    (
      selectedType: selectedType,
      searchQuery: searchQuery,
      isReloading: isReloading,
      isEmpty:
          !isReloading &&
          pokemon.isEmpty &&
          (selectedType != null || searchQuery.isNotEmpty),
    ),
  PokemonListInitial() || PokemonListLoading() => (
    selectedType: null,
    searchQuery: '',
    isReloading: true,
    isEmpty: false,
  ),
  _ => (
    selectedType: null,
    searchQuery: '',
    isReloading: false,
    isEmpty: false,
  ),
};

_GridSlice _gridSlice(PokemonListState state) => switch (state) {
  PokemonListSuccess(
    :final pokemon,
    :final isReloading,
    :final selectedType,
    :final searchQuery,
  ) =>
    (
      pokemon: pokemon,
      isReloading: isReloading,
      selectedType: selectedType,
      searchQuery: searchQuery,
    ),
  PokemonListInitial() || PokemonListLoading() => (
    pokemon: const <Pokemon>[],
    isReloading: true,
    selectedType: null,
    searchQuery: '',
  ),
  _ => (
    pokemon: const <Pokemon>[],
    isReloading: false,
    selectedType: null,
    searchQuery: '',
  ),
};

_FooterSlice _footerSlice(PokemonListState state) => switch (state) {
  PokemonListSuccess(
    :final isReloading,
    :final hasNext,
    :final isLoadingMore,
    :final loadMoreFailure,
  ) =>
    (
      showFooter:
          !isReloading && (hasNext || isLoadingMore || loadMoreFailure != null),
      isLoadingMore: isLoadingMore,
      loadMoreFailure: loadMoreFailure,
    ),
  _ => (showFooter: false, isLoadingMore: false, loadMoreFailure: null),
};

class _PokemonGrid extends StatelessWidget {
  const _PokemonGrid({required this.scrollController, required this.onRefresh});

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = crossAxisCountForWidth(constraints.maxWidth);

        return CustomScrollView(
          controller: scrollController,
          slivers: [
            BlocSelector<PokemonListCubit, PokemonListState, _ChromeSlice>(
              selector: _chromeSlice,
              builder: (context, chrome) {
                return CupertinoSliverNavigationBar.search(
                  largeTitle: Text(context.pokemonStrings.appTitle),
                  searchField: PokemonSearchField(
                    searchQuery: chrome.searchQuery,
                  ),
                  bottomMode: NavigationBarBottomMode.automatic,
                );
              },
            ),
            BlocSelector<PokemonListCubit, PokemonListState, _ChromeSlice>(
              selector: _chromeSlice,
              builder: (context, chrome) {
                return PokemonTypeFilterHeader(
                  types: allPokemonTypes,
                  selectedType: chrome.selectedType,
                  isEmpty: chrome.isEmpty,
                );
              },
            ),
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
            BlocSelector<PokemonListCubit, PokemonListState, _GridSlice>(
              selector: _gridSlice,
              builder: (context, grid) {
                return PokemonFilterTransitionSliver(
                  pokemon: grid.pokemon,
                  isReloading: grid.isReloading,
                  selectedType: grid.selectedType,
                  searchQuery: grid.searchQuery,
                  crossAxisCount: crossAxisCount,
                );
              },
            ),
            BlocSelector<PokemonListCubit, PokemonListState, _FooterSlice>(
              selector: _footerSlice,
              builder: (context, footer) {
                if (!footer.showFooter) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: PokemonGridFooter(
                    isLoadingMore: footer.isLoadingMore,
                    loadMoreFailure: footer.loadMoreFailure,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
