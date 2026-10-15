import 'package:pokemon/domain/models/type.dart';

sealed class PokemonListCommand {
  const PokemonListCommand();
}

final class LoadPokemonListCommand extends PokemonListCommand {
  const LoadPokemonListCommand();
}

final class RefreshPokemonListCommand extends PokemonListCommand {
  const RefreshPokemonListCommand();
}

final class LoadMorePokemonListCommand extends PokemonListCommand {
  const LoadMorePokemonListCommand();
}

final class FilterPokemonListCommand extends PokemonListCommand {
  const FilterPokemonListCommand(this.type);

  final Type? type;
}

final class SearchPokemonListCommand extends PokemonListCommand {
  const SearchPokemonListCommand(this.query);

  final String query;
}
