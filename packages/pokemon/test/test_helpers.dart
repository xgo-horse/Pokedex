import 'package:flutter/cupertino.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/domain/models/pokemon_list_page.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/l10n/app_localizations.dart';

Pokemon testPokemon({
  int id = 1,
  String name = 'bulbasaur',
  List<Type>? types,
}) {
  return Pokemon(
    id: id,
    name: name,
    imageUrl: Uri.parse('https://example.com/$id.png'),
    types: types ?? [Grass(), Poison()],
  );
}

PokemonListPage testPokemonListPage({
  List<Pokemon>? pokemon,
  bool hasNext = false,
}) {
  final items = pokemon ?? [testPokemon()];
  return PokemonListPage(
    pokemon: items,
    totalCount: items.length,
    hasNext: hasNext,
  );
}

Widget testApp({Widget? home}) => CupertinoApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

Future<AppLocalizations> englishLocalizations() =>
    AppLocalizations.delegate.load(const Locale('en'));
