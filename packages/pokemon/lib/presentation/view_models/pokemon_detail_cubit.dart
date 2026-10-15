import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/use_cases/get_pokemon_detail.dart';
import 'package:pokemon/presentation/commands/pokemon_detail_command.dart';

class PokemonDetailCubit extends Cubit<LoadState<Pokemon>> {
  PokemonDetailCubit(this._getPokemonDetail) : super(const LoadInitial());

  final GetPokemonDetail _getPokemonDetail;

  Future<void> execute(PokemonDetailCommand command) async => switch (command) {
    LoadPokemonDetailCommand(:final id) ||
    RefreshPokemonDetailCommand(:final id) => _load(id),
  };

  Future<void> _load(int id) async {
    emit(const LoadLoading());
    final result = await _getPokemonDetail(id);
    emit(switch (result) {
      Right(:final value) => LoadSuccess(value),
      Left(:final value) => LoadFailure(value),
    });
  }
}
