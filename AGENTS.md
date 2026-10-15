# AGENTS.md

Instructions for AI coding agents working in this repository.

**Architecture & standards:** see [`.cursor/rules/`](.cursor/rules) — `flutter-mvvm-core.mdc` always applies; the layer rules (`dart-style`, `domain-layer`, `data-layer`, `presentation-layer`, `app-shell`, `testing`) attach to matching files. Those rules are domain-neutral and double as the reusable template; see [`docs/templates/README.md`](docs/templates/README.md) to copy them into another project.

This file is the **project overlay** — names, paths, commands, and where this repo deviates from the template. It does not repeat the architecture rules.

## Project overview

Flutter Pokédex app using **MVVM** in a **Dart workspace monorepo**. The root app (`pokedex`) is the Flutter shell; shared logic lives in `packages/*`.

| Path | Purpose |
|------|---------|
| `lib/` | App entry point, GoRouter config, **GetIt** dependency injection |
| `packages/core/` | Shared utilities: `Either`, `Failure`, `LoadState` |
| `packages/pokemon/` | Pokémon feature — Model (`domain/`, `data/`), View + ViewModel (`presentation/`) |

**Stack:** Dart 3.12+ (Flutter SDK compatible with that SDK), `flutter_lints`, `go_router`, `flutter_bloc`, `get_it`, `drift`, `http`.

App imports: `package:core/...`, `package:pokemon/...`.

## Naming map

The rules use a neutral `catalog` / `Item` example. In this repo:

| Template | Here |
|----------|------|
| `catalog` package | `pokemon` |
| `Item` entity | `Pokemon` (`domain/models/pokemon.dart`) |
| `ItemCategory` | `Type` (`domain/models/type.dart`) — **not** `PokemonType` |
| `LoadItemList` | `LoadPokemonList`, `GetPokemonDetail` |
| Filter strategies | `AllPokemonFilter`, `TypePokemonFilter` |
| Routes | `/pokemon`, `/pokemon/:id` |

## Live reference implementation

Read these files rather than a copied snippet — they are the current source of truth for the vertical slice:

- ViewModel: `packages/pokemon/lib/presentation/view_models/pokemon_list_cubit.dart`
- State: `packages/pokemon/lib/presentation/view_models/pokemon_list_state.dart`
- Intents / Actions / Commands: `packages/pokemon/lib/presentation/{intents,actions,commands}/pokemon_list_*.dart`
- View: `packages/pokemon/lib/presentation/views/pokemon_list_screen.dart`
- Use case → repository → data source: `packages/pokemon/lib/domain/use_cases/load_pokemon_list.dart`, `packages/pokemon/lib/data/repositories/data_source_pokemon_repository.dart`

Notes on where this slice goes beyond the template:

- `PokemonListCubit` uses a feature-specific sealed `PokemonListState` instead of `LoadState<T>`, because the list needs paging (`hasNext`, `fetchOffset`, `isLoadingMore`) and a reload-in-place flag. `PokemonDetailCubit` uses `LoadState<T>`. Reach for `LoadState<T>` first; define a feature state only when the screen needs fields it cannot carry.
- The list Cubit guards against out-of-order responses with a `_loadGeneration` counter — preserve that when adding load paths.

## Data sources

`PokemonDataSource` has several implementations, selected in `lib/di/injection.dart`:

- Remote: `PokeApiPokemonDataSource` (REST) or `PokeApiGraphqlPokemonDataSource`, chosen by the `POKEMON_DATA_SOURCE` compile-time variable (`graphql` by default).
- Local cache: `DriftPokemonDataSource`, falling back to `MemoryPokemonDataSource` on web (drift needs wasm/worker assets).

Adding a data source means registering it in `lib/di/injection.dart` — the feature package never calls `GetIt`.

`lib/di/injection.dart` deep-imports internal `package:pokemon/...` paths that the `pokemon.dart` barrel does not export. That is the intended exception for the composition root; application code should import through the barrel.

## Build & test commands

Run from the repository root unless noted.

```bash
# Resolve workspace dependencies
dart pub get

# Static analysis (run after code changes)
dart analyze

# Format changed files
dart format .

# Run the app (pick a device when prompted)
flutter run

# Run the app against the REST data source
flutter run --dart-define=POKEMON_DATA_SOURCE=rest

# Run all tests
flutter test

# Run tests for a single package
cd packages/pokemon && flutter test

# Regenerate drift code after editing lib/data/local/tables/
cd packages/pokemon && dart run build_runner build --delete-conflicting-outputs

# Regenerate localizations after editing lib/l10n/*.arb
cd packages/pokemon && flutter gen-l10n
```

Before finishing a task, run `dart analyze` and fix any issues. Run `dart format .` on files you changed.
