import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokemon/domain/use_cases/load_pokemon_list.dart';
import 'package:pokemon/presentation/commands/pokemon_list_command.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_cubit.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_state.dart';
import 'package:pokemon/presentation/views/pokemon_list_screen.dart';
import 'package:pokemon/presentation/actions/pokemon_list_action.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_search_field.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_fade.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_tile_skeleton.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_type_filter_bar.dart';

import '../../test_helpers.dart';

class _StubPokemonListCubit extends PokemonListCubit {
  _StubPokemonListCubit() : super(_UnimplementedLoadPokemonList());

  void emitState(PokemonListState state) => emit(state);
}

class _RecordingPokemonListCubit extends PokemonListCubit {
  _RecordingPokemonListCubit() : super(_UnimplementedLoadPokemonList());

  final commands = <PokemonListCommand>[];

  void emitState(PokemonListState state) => emit(state);

  @override
  Future<void> execute(PokemonListCommand command) async {
    commands.add(command);
  }
}

class _UnimplementedLoadPokemonList extends LoadPokemonList {
  _UnimplementedLoadPokemonList() : super(_ThrowingRepository());
}

class _ThrowingRepository implements PokemonRepository {
  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) {
    throw UnimplementedError();
  }
}

Widget _wrap(Widget child, PokemonListCubit cubit) {
  return testApp(
    home: BlocProvider<PokemonListCubit>.value(value: cubit, child: child),
  );
}

void main() {
  late _StubPokemonListCubit cubit;

  setUp(() {
    cubit = _StubPokemonListCubit();
  });

  tearDown(() => cubit.close());

  testWidgets('shows skeleton grid while reloading', (tester) async {
    final l10n = await englishLocalizations();
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    cubit.emitState(
      const PokemonListSuccess(
        pokemon: [],
        hasNext: false,
        fetchOffset: 0,
        isReloading: true,
      ),
    );

    await tester.pumpWidget(_wrap(const PokemonListScreen(), cubit));
    await tester.pump();

    expect(find.byType(PokemonGridTileSkeleton), findsWidgets);
    expect(find.text(l10n.filterAll), findsOneWidget);
    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
  });

  testWidgets('shows pokemon grid on success', (tester) async {
    cubit.emitState(
      PokemonListSuccess(
        pokemon: [testPokemon()],
        hasNext: false,
        fetchOffset: 30,
      ),
    );

    await tester.pumpWidget(_wrap(const PokemonListScreen(), cubit));
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('#001'), findsOneWidget);
  });

  testWidgets('shows empty filter message', (tester) async {
    final l10n = await englishLocalizations();
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    cubit.emitState(
      PokemonListSuccess(
        pokemon: const [],
        hasNext: false,
        fetchOffset: 30,
        selectedType: Fire(),
      ),
    );

    await tester.pumpWidget(_wrap(const PokemonListScreen(), cubit));
    await tester.pump();
    await tester.pump(kPokemonGridFadeDuration);

    // Shown on the filter bar and in the grid empty state.
    expect(find.text(l10n.filterEmptyMessage), findsNWidgets(2));
  });

  testWidgets('shows empty search message', (tester) async {
    final l10n = await englishLocalizations();
    cubit.emitState(
      const PokemonListSuccess(
        pokemon: [],
        hasNext: false,
        fetchOffset: 0,
        searchQuery: 'zzz',
      ),
    );

    await tester.pumpWidget(_wrap(const PokemonListScreen(), cubit));
    await tester.pump();
    await tester.pump(kPokemonGridFadeDuration);

    expect(find.text(l10n.searchEmptyMessage), findsOneWidget);
    expect(find.text(l10n.filterEmptyMessage), findsNothing);
  });

  testWidgets('renders type filter header below search navigation bar', (tester) async {
    cubit.emitState(
      PokemonListSuccess(
        pokemon: [testPokemon()],
        hasNext: false,
        fetchOffset: 30,
      ),
    );

    await tester.pumpWidget(_wrap(const PokemonListScreen(), cubit));
    await tester.pumpAndSettle();

    expect(find.byType(PokemonTypeFilterBar), findsOneWidget);
  });

  testWidgets('debounces search intent dispatch', (tester) async {
    final recordingCubit = _RecordingPokemonListCubit();
    addTearDown(recordingCubit.close);

    await tester.pumpWidget(
      testApp(
        home: BlocProvider<PokemonListCubit>.value(
          value: recordingCubit,
          child: Actions(
            actions: {
              SearchPokemonListIntent: SearchPokemonListAction(),
            },
            child: const CupertinoPageScaffold(
              child: Center(
                child: PokemonSearchField(
                  searchQuery: '',
                  debounceDuration: Duration(milliseconds: 50),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoSearchTextField), 'char');
    await tester.pump(const Duration(milliseconds: 30));
    expect(
      recordingCubit.commands.whereType<SearchPokemonListCommand>(),
      isEmpty,
    );

    await tester.pump(const Duration(milliseconds: 30));
    expect(
      recordingCubit.commands.whereType<SearchPokemonListCommand>().single.query,
      'char',
    );
  });

  testWidgets('shows latest filter after rapid cached filter switches', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cubit = PokemonListCubit(LoadPokemonList(_InstantTypeRepository()));

    await tester.pumpWidget(_wrap(const PokemonListScreen(), cubit));
    await cubit.execute(const LoadPokemonListCommand());
    await tester.pumpAndSettle();

    await cubit.execute(FilterPokemonListCommand(Water()));
    await cubit.execute(FilterPokemonListCommand(Grass()));
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Squirtle'), findsNothing);
    await cubit.close();
  });
}

class _InstantTypeRepository implements PokemonRepository {
  @override
  Future<Either<Failure, PokemonListPage>> getPokemonPage({
    required int limit,
    required int offset,
    Type? type,
    String? nameQuery,
    bool forceRefresh = false,
  }) async {
    if (type is Water) {
      return Right(
        PokemonListPage(
          pokemon: [
            testPokemon(id: 7, name: 'squirtle', types: [Water()]),
          ],
          totalCount: 1,
          hasNext: false,
        ),
      );
    }
    if (type is Grass) {
      return Right(
        PokemonListPage(
          pokemon: [
            testPokemon(id: 1, name: 'bulbasaur', types: [Grass()]),
          ],
          totalCount: 1,
          hasNext: false,
        ),
      );
    }
    return Right(
      PokemonListPage(pokemon: [testPokemon()], totalCount: 1, hasNext: false),
    );
  }

  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) {
    throw UnimplementedError();
  }
}
