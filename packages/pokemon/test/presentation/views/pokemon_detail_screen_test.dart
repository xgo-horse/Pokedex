import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokemon/domain/use_cases/get_pokemon_detail.dart';
import 'package:pokemon/presentation/view_models/pokemon_detail_cubit.dart';
import 'package:pokemon/presentation/views/pokemon_detail_screen.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_detail_body.dart';

import '../../test_helpers.dart';

class _StubPokemonDetailCubit extends PokemonDetailCubit {
  _StubPokemonDetailCubit() : super(_UnimplementedGetPokemonDetail());

  void emitState(LoadState<Pokemon> state) => emit(state);
}

class _UnimplementedGetPokemonDetail extends GetPokemonDetail {
  _UnimplementedGetPokemonDetail() : super(_ThrowingRepository());
}

class _ThrowingRepository implements PokemonRepository {
  @override
  Future<Either<Failure, Pokemon>> getPokemonById(int id) {
    throw UnimplementedError();
  }

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
}

Widget _wrap(Widget child, PokemonDetailCubit cubit) {
  return testApp(
    home: BlocProvider<PokemonDetailCubit>.value(value: cubit, child: child),
  );
}

void main() {
  late _StubPokemonDetailCubit cubit;

  setUp(() {
    cubit = _StubPokemonDetailCubit();
  });

  tearDown(() => cubit.close());

  testWidgets('shows loading indicator', (tester) async {
    cubit.emitState(const LoadLoading());

    await tester.pumpWidget(_wrap(const PokemonDetailScreen(id: 1), cubit));

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('shows passed name in nav bar while loading', (tester) async {
    cubit.emitState(const LoadLoading());

    await tester.pumpWidget(
      _wrap(const PokemonDetailScreen(id: 25, name: 'pikachu'), cubit),
    );

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('shows pokemon detail on success', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    cubit.emitState(LoadSuccess(testPokemon(id: 25, name: 'pikachu')));

    await tester.pumpWidget(
      _wrap(const PokemonDetailScreen(id: 25, name: 'pikachu'), cubit),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PokemonDetailBody), findsOneWidget);
    expect(find.text('Pikachu'), findsWidgets);
  });

  testWidgets('shows retry on failure', (tester) async {
    final l10n = await englishLocalizations();
    cubit.emitState(const LoadFailure(NetworkFailure('Offline')));

    await tester.pumpWidget(_wrap(const PokemonDetailScreen(id: 1), cubit));
    await tester.pumpAndSettle();

    expect(find.text(l10n.networkFailureMessage), findsOneWidget);
    expect(find.text(l10n.retry), findsOneWidget);
  });
}
