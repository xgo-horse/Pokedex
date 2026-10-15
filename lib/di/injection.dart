import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:pokemon/data/api/poke_api_client.dart';
import 'package:pokemon/data/api/poke_api_graphql_client.dart';
import 'package:pokemon/data/local/app_database.dart';
import 'package:pokemon/data/repositories/data_source_pokemon_repository.dart';
import 'package:pokemon/data/sources/drift_pokemon_data_source.dart';
import 'package:pokemon/data/sources/local_pokemon_data_source.dart';
import 'package:pokemon/data/sources/memory_pokemon_data_source.dart';
import 'package:pokemon/data/sources/poke_api_graphql_pokemon_data_source.dart';
import 'package:pokemon/data/sources/poke_api_pokemon_data_source.dart';
import 'package:pokemon/data/sources/pokemon_data_source.dart';
import 'package:pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokemon/domain/use_cases/get_pokemon_detail.dart';
import 'package:pokemon/domain/use_cases/load_pokemon_list.dart';

import 'pokemon_data_source_kind.dart';

final getIt = GetIt.instance;

/// Registers app-wide dependencies. Call from `main` before `runApp`.
Future<void> configureDependencies() async {
  getIt.registerLazySingleton<http.Client>(http.Client.new);
  getIt.registerLazySingleton(() => PokeApiClient(getIt()));
  getIt.registerLazySingleton(() => PokeApiGraphqlClient(getIt()));

  // Drift needs web wasm/worker assets; use an in-memory cache on web.
  if (kIsWeb) {
    getIt.registerLazySingleton<LocalPokemonDataSource>(
      MemoryPokemonDataSource.new,
    );
  } else {
    getIt.registerLazySingleton<AppDatabase>(AppDatabase.defaults);
    getIt.registerLazySingleton<LocalPokemonDataSource>(
      () => DriftPokemonDataSource(getIt()),
    );
  }

  final dataSourceKind = pokemonDataSourceKindFromEnvironment();
  getIt.registerLazySingleton<PokemonDataSource>(
    () => switch (dataSourceKind) {
      PokemonDataSourceKind.rest => PokeApiPokemonDataSource(getIt(), getIt()),
      PokemonDataSourceKind.graphql => PokeApiGraphqlPokemonDataSource(getIt()),
    },
  );
  getIt.registerLazySingleton<PokemonRepository>(
    () => DataSourcePokemonRepository(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => LoadPokemonList(getIt()));
  getIt.registerLazySingleton(() => GetPokemonDetail(getIt()));
}
