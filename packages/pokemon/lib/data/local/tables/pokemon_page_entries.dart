import 'package:drift/drift.dart';

class PokemonPageEntries extends Table {
  IntColumn get pageLimit => integer()();
  IntColumn get pageOffset => integer()();
  TextColumn get typeName => text().withDefault(const Constant(''))();
  IntColumn get totalCount => integer()();
  BoolColumn get hasNext => boolean()();
  TextColumn get pokemonIdsJson => text()();
  IntColumn get cachedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {pageLimit, pageOffset, typeName};
}
