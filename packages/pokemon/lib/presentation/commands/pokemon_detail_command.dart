sealed class PokemonDetailCommand {
  const PokemonDetailCommand();
}

final class LoadPokemonDetailCommand extends PokemonDetailCommand {
  const LoadPokemonDetailCommand(this.id);

  final int id;
}

final class RefreshPokemonDetailCommand extends PokemonDetailCommand {
  const RefreshPokemonDetailCommand(this.id);

  final int id;
}
