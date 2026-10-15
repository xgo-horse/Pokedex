import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:pokemon/domain/models/type.dart';
import 'package:pokemon/l10n/app_localizations.dart';

extension PokemonLocalizations on AppLocalizations {
  String failureMessage(Failure failure) => switch (failure) {
    NetworkFailure() => networkFailureMessage,
    UnexpectedFailure() => unexpectedFailureMessage,
  };

  String pokemonType(Type type) => switch (type) {
    Normal() => pokemonTypeNormal,
    Fire() => pokemonTypeFire,
    Water() => pokemonTypeWater,
    Grass() => pokemonTypeGrass,
    Electric() => pokemonTypeElectric,
    Ice() => pokemonTypeIce,
    Fighting() => pokemonTypeFighting,
    Poison() => pokemonTypePoison,
    Ground() => pokemonTypeGround,
    Flying() => pokemonTypeFlying,
    Psychic() => pokemonTypePsychic,
    Bug() => pokemonTypeBug,
    Rock() => pokemonTypeRock,
    Ghost() => pokemonTypeGhost,
    Dragon() => pokemonTypeDragon,
    Dark() => pokemonTypeDark,
    Steel() => pokemonTypeSteel,
    Fairy() => pokemonTypeFairy,
  };
}

extension PokemonLocalizationsContext on BuildContext {
  AppLocalizations get pokemonStrings => AppLocalizations.of(this)!;
}
