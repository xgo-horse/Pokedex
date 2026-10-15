import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon/domain/models/pokemon_types.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/presentation/commands/pokemon_list_command.dart';
import 'package:pokemon/presentation/intents/pokemon_list_intent.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_cubit.dart';
import 'package:pokemon/presentation/view_models/pokemon_list_state.dart';

final class LoadPokemonListAction extends ContextAction<LoadPokemonListIntent> {
  @override
  void invoke(LoadPokemonListIntent intent, [BuildContext? context]) {
    context?.read<PokemonListCubit>().execute(const LoadPokemonListCommand());
  }
}

final class RefreshPokemonListAction
    extends ContextAction<RefreshPokemonListIntent> {
  @override
  void invoke(RefreshPokemonListIntent intent, [BuildContext? context]) {
    final targetContext = context ?? primaryFocus?.context;
    if (targetContext == null) {
      return;
    }
    targetContext.read<PokemonListCubit>().execute(
      const RefreshPokemonListCommand(),
    );
  }
}

final class LoadMorePokemonListAction
    extends ContextAction<LoadMorePokemonListIntent> {
  @override
  void invoke(LoadMorePokemonListIntent intent, [BuildContext? context]) {
    context?.read<PokemonListCubit>().execute(
      const LoadMorePokemonListCommand(),
    );
  }
}

final class FilterPokemonListAction
    extends ContextAction<FilterPokemonListIntent> {
  @override
  void invoke(FilterPokemonListIntent intent, [BuildContext? context]) {
    context?.read<PokemonListCubit>().execute(
      FilterPokemonListCommand(intent.type),
    );
  }
}

final class SearchPokemonListAction
    extends ContextAction<SearchPokemonListIntent> {
  @override
  void invoke(SearchPokemonListIntent intent, [BuildContext? context]) {
    context?.read<PokemonListCubit>().execute(
      SearchPokemonListCommand(intent.query),
    );
  }
}

final class CyclePokemonFilterAction
    extends ContextAction<CyclePokemonFilterIntent> {
  @override
  void invoke(CyclePokemonFilterIntent intent, [BuildContext? context]) {
    final targetContext = context ?? primaryFocus?.context;
    if (targetContext == null) {
      return;
    }

    final cubit = targetContext.read<PokemonListCubit>();
    final Type? selected = switch (cubit.state) {
      PokemonListSuccess(:final selectedType) => selectedType,
      _ => null,
    };
    final next = cyclePokemonTypeFilter(selected, delta: intent.delta);
    cubit.execute(FilterPokemonListCommand(next));
  }
}

final class OpenPokemonDetailAction
    extends ContextAction<OpenPokemonDetailIntent> {
  @override
  void invoke(OpenPokemonDetailIntent intent, [BuildContext? context]) {
    context?.push(
      Uri(
        path: '/pokemon/${intent.id}',
        queryParameters: {'name': intent.name},
      ).toString(),
    );
  }
}
