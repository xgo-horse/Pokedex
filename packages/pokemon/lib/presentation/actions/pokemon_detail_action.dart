import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokemon/presentation/commands/pokemon_detail_command.dart';
import 'package:pokemon/presentation/intents/pokemon_detail_intent.dart';
import 'package:pokemon/presentation/view_models/pokemon_detail_cubit.dart';

final class LoadPokemonDetailAction
    extends ContextAction<LoadPokemonDetailIntent> {
  LoadPokemonDetailAction(this.id);

  final int id;

  @override
  void invoke(LoadPokemonDetailIntent intent, [BuildContext? context]) {
    context?.read<PokemonDetailCubit>().execute(LoadPokemonDetailCommand(id));
  }
}

final class RefreshPokemonDetailAction
    extends ContextAction<RefreshPokemonDetailIntent> {
  RefreshPokemonDetailAction(this.id);

  final int id;

  @override
  void invoke(RefreshPokemonDetailIntent intent, [BuildContext? context]) {
    context?.read<PokemonDetailCubit>().execute(
      RefreshPokemonDetailCommand(id),
    );
  }
}
