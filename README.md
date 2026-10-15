# Pokédex — estudo de arquitetura MVVM em Flutter

Uma Pokédex feita em Flutter cujo objetivo principal **não é o app em si, mas a arquitetura**: um estudo de como organizar um projeto Flutter em **MVVM** com camadas bem separadas, dependências explícitas e código fácil de testar.

Os dados vêm da [PokéAPI](https://pokeapi.co/) (REST ou GraphQL), com cache local em SQLite via [drift](https://drift.simonbinder.eu/).

## Funcionalidades

- Lista paginada de Pokémon com scroll infinito
- Filtro por tipo e busca por nome (com tolerância a erros de digitação)
- Tela de detalhes
- Cache local: o que já foi carregado abre sem rede
- Atalhos de teclado (`R` recarrega, `0` limpa o filtro, `[` / `]` alternam entre tipos)
- Interface em inglês e português

## Stack

| Uso | Pacote |
|-----|--------|
| ViewModels | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (Cubit) |
| Injeção de dependência | [`get_it`](https://pub.dev/packages/get_it) |
| Navegação | [`go_router`](https://pub.dev/packages/go_router) |
| Rede | [`http`](https://pub.dev/packages/http) |
| Cache local | [`drift`](https://pub.dev/packages/drift) |
| Testes | `flutter_test`, [`bloc_test`](https://pub.dev/packages/bloc_test) |

Dart 3.12+ — o código usa bastante `sealed class`, `switch` com pattern matching e records.

## Arquitetura

### Visão geral do MVVM

| Camada MVVM | Onde fica | Responsabilidade |
|-------------|-----------|------------------|
| **Model** | `domain/` + `data/` | Entidades, regras de negócio, casos de uso, acesso a API e cache |
| **View** | `presentation/views/` | Widgets Flutter. Só desenha o estado e dispara *Intents* — sem lógica de negócio |
| **ViewModel** | `presentation/view_models/` | *Cubits* que recebem *Commands*, chamam casos de uso e emitem estado |

### Fluxo de uma ação do usuário

```
View ──Intent──▶ Action ──Command──▶ Cubit (ViewModel) ──▶ UseCase ──▶ Repository ──▶ DataSource
  ▲                                       │
  └──────────── estado (sealed) ◀─────────┘
```

Exemplo: o usuário escolhe o tipo "Fogo" na barra de filtros.

1. **View** — o widget chama `Actions.invoke(context, FilterPokemonListIntent(type))`. Ele não conhece o Cubit.
2. **Intent / Action** — `FilterPokemonListAction` pega o Cubit do contexto e envia `FilterPokemonListCommand(type)`.
3. **ViewModel** — `PokemonListCubit.execute()` faz um `switch` sobre os comandos (uma `sealed class`) e chama o caso de uso `LoadPokemonList`.
4. **Domain** — o caso de uso pede a página ao `PokemonRepository` (uma interface).
5. **Data** — `DataSourcePokemonRepository` tenta o cache local e, se não houver nada, busca na API e salva o resultado.
6. O resultado volta como `Either<Failure, T>`, e o Cubit emite um novo `PokemonListState`, que a View redesenha com `BlocBuilder`.

### Por que Intents e Actions?

Usar `Intent` + `Action` (do próprio Flutter) em vez de chamar o Cubit direto no `onPressed` faz com que **toda ação da tela possa ser ligada a um atalho de teclado** sem duplicar código. Um botão e a tecla `R` disparam o mesmo `RefreshPokemonListIntent`.

Os **Commands** são o único ponto de entrada do Cubit (`execute(command)`). Como são `sealed`, o compilador avisa se algum comando não for tratado.

### Camadas

**`domain/`** — Dart puro, sem imports de Flutter.
- `models/` — entidades (`Pokemon`, `Type`, `PokemonListPage`)
- `repositories/` — interfaces (`PokemonRepository`)
- `use_cases/` — `LoadPokemonList`, `GetPokemonDetail`: o que os ViewModels podem pedir
- `strategies/` — algoritmos que podem ser trocados entre si (padrão *Strategy*): `AllPokemonFilter`, `TypePokemonFilter`, `FuzzyNamePokemonFilter` (busca aproximada com distância de Levenshtein)

**`data/`** — implementa o domínio.
- `api/` + `poke_api*/` — clientes HTTP e DTOs da PokéAPI (REST e GraphQL)
- `sources/` — fontes de dados: remotas (`PokeApiPokemonDataSource`, `PokeApiGraphqlPokemonDataSource`) e locais (`DriftPokemonDataSource`, e `MemoryPokemonDataSource` na web)
- `repositories/` — `DataSourcePokemonRepository` junta a fonte remota e a local (cache primeiro, rede como fallback)
- Erros viram `Failure` e são devolvidos como `Left`; nada de exceções atravessando camadas

**`presentation/`** — Flutter.
- `intents/`, `actions/`, `commands/` — o fluxo descrito acima
- `view_models/` — `PokemonListCubit` (estado próprio, com paginação) e `PokemonDetailCubit` (usa o `LoadState<T>` genérico)
- `views/` — telas e widgets

**`lib/` (casca do app)** — o *composition root*.
- `di/injection.dart` — registra todas as dependências no GetIt. É o único lugar que escolhe implementações concretas.
- `router/app_router.dart` — rotas do GoRouter (`/pokemon`, `/pokemon/:id`), que criam os Cubits com `BlocProvider`

### Monorepo com Dart workspace

```
pokedex/
├── lib/                 # App: main, DI, rotas
├── packages/
│   ├── core/            # Either, Failure, LoadState — compartilhados por todas as features
│   └── pokemon/         # A feature Pokémon: domain / data / presentation
└── pubspec.yaml         # workspace: packages/*
```

Cada feature é um pacote isolado. O pacote `pokemon` nunca chama o GetIt: recebe tudo pelo construtor, então pode ser testado sem o app.

### Decisões que valem destacar

- **`Either<Failure, T>` em vez de exceções** — os erros fazem parte da assinatura, e o `switch` obriga quem chama a tratar os dois casos.
- **Estado como `sealed class`** — a View faz `switch` sobre o estado e o compilador garante que todos os casos estão cobertos.
- **`LoadState<T>` primeiro, estado próprio só quando necessário** — a lista precisa de paginação (`hasNext`, `fetchOffset`, `isLoadingMore`) e de recarregar sem limpar a tela, por isso tem o `PokemonListState`. Os detalhes usam o `LoadState<T>` genérico.
- **Proteção contra respostas fora de ordem** — o `PokemonListCubit` numera cada carregamento (`_loadGeneration`) e descarta respostas antigas. Se o usuário trocar de filtro rápido, uma resposta lenta não sobrescreve a mais nova.
- **Fonte de dados trocável** — REST ou GraphQL é escolhido por uma variável de compilação, sem mudar uma linha da feature.

## Como rodar

```bash
dart pub get
flutter run
```

Por padrão o app usa a API GraphQL. Para usar a REST:

```bash
flutter run --dart-define=POKEMON_DATA_SOURCE=rest
```

### Testes e análise

```bash
flutter test
dart analyze
```

Os testes ficam em `packages/pokemon/test/` e espelham a estrutura de `lib/`: casos de uso, estratégias, repositório, fontes de dados, Cubits (com `bloc_test`), telas e um teste de golden.

### Código gerado

```bash
# Depois de alterar as tabelas do drift (packages/pokemon/lib/data/local/tables/)
cd packages/pokemon && dart run build_runner build --delete-conflicting-outputs

# Depois de alterar as traduções (packages/pokemon/lib/l10n/*.arb)
cd packages/pokemon && flutter gen-l10n
```

## Reutilizando a arquitetura

As regras da arquitetura estão em [`.cursor/rules/`](.cursor/rules), escritas de forma neutra (com um domínio genérico `catalog` / `Item`). Elas servem de template para outros projetos — veja [`docs/templates/README.md`](docs/templates/README.md). O [`AGENTS.md`](AGENTS.md) mostra como os nomes do template correspondem aos deste projeto.
