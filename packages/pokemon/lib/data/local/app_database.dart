import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:pokemon/data/local/tables/pokemon_entries.dart';
import 'package:pokemon/data/local/tables/pokemon_page_entries.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [PokemonEntries, PokemonPageEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.defaults() : super(driftDatabase(name: 'pokemon_cache'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.deleteTable('pokemon_page_entries');
        await migrator.createTable(pokemonPageEntries);
      }
      if (from < 3) {
        await migrator.addColumn(pokemonEntries, pokemonEntries.cachedAt);
        await migrator.addColumn(
          pokemonPageEntries,
          pokemonPageEntries.cachedAt,
        );
      }
    },
  );
}
