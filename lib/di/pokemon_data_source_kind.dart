enum PokemonDataSourceKind { rest, graphql }

PokemonDataSourceKind pokemonDataSourceKindFromEnvironment() {
  const raw = String.fromEnvironment(
    'POKEMON_DATA_SOURCE',
    defaultValue: 'graphql',
  );
  return switch (raw) {
    'graphql' => PokemonDataSourceKind.graphql,
    'rest' => PokemonDataSourceKind.rest,
    _ => PokemonDataSourceKind.rest,
  };
}
