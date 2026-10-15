import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon/pokemon.dart';

import '../di/injection.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/pokemon'),
    GoRoute(
      path: '/pokemon',
      builder: (context, state) => BlocProvider(
        create: (_) =>
            PokemonListCubit(getIt<LoadPokemonList>())
              ..execute(const LoadPokemonListCommand()),
        child: const PokemonListScreen(),
      ),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final name = state.uri.queryParameters['name'];
            return BlocProvider(
              create: (_) =>
                  PokemonDetailCubit(getIt<GetPokemonDetail>())
                    ..execute(LoadPokemonDetailCommand(id)),
              child: PokemonDetailScreen(id: id, name: name),
            );
          },
        ),
      ],
    ),
  ],
);
