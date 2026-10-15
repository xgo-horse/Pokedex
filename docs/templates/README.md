# Reusing this architecture in another project

The rules in [`.cursor/rules/`](../../.cursor/rules) **are** the template. They contain no Pokédex-specific names — the example domain is a neutral `catalog` package with an `Item` entity — so there is no separate copy to keep in sync.

## Steps

1. Copy the rule files into the new project:

   ```bash
   mkdir -p <new-project>/.cursor/rules
   cp .cursor/rules/*.mdc <new-project>/.cursor/rules/
   ```

2. Delete the sync comment at the top of `flutter-mvvm-core.mdc` — it points back at this repo.
3. Adjust the globs if the new project is not a workspace monorepo (see below).
4. Copy [`AGENTS.md.template`](AGENTS.md.template) to the project root as `AGENTS.md` and fill it in.
5. Replace the neutral `catalog` / `Item` names in the new project's `AGENTS.md` naming map — leave the rules themselves neutral.

## What each rule does

| Rule | Applies | Covers |
|------|---------|--------|
| `flutter-mvvm-core.mdc` | always | Workspace layout, MVVM layer table, dependency flow, boundaries, git |
| `dart-style.mdc` | `**/*.dart` | Effective Dart, sealed classes, pattern matching, `Either` |
| `domain-layer.mdc` | `packages/*/lib/domain/**/*.dart` | Use cases, strategies |
| `data-layer.mdc` | `packages/*/lib/data/**/*.dart` | Data sources, repository implementations, failure mapping |
| `presentation-layer.mdc` | `packages/*/lib/presentation/**/*.dart` | Intents, Actions, Commands, Cubits, Views |
| `app-shell.mdc` | `lib/**/*.dart` | GetIt registration, GoRouter |
| `testing.mdc` | `**/*_test.dart` | Test placement, Cubit tests |

Only the core rule is `alwaysApply: true`; the rest attach when a matching file is in context. That keeps the per-turn baseline near 110 lines instead of the ~515 lines these bodies total when merged — Cursor's guidance is to keep a rule under 500 lines and split large rules by concern.

## Adapting the globs

The globs assume the workspace monorepo described in `flutter-mvvm-core.mdc`. In a **single-package app** where feature code lives directly under `lib/`:

- Layer rules become `lib/domain/**/*.dart`, `lib/data/**/*.dart`, `lib/presentation/**/*.dart`.
- Narrow the app-shell glob to `lib/di/**/*.dart,lib/router/**/*.dart,lib/main.dart`. As written, `lib/**/*.dart` would match every file in the project.

## Keep the placement map in the always-apply rule

Cursor's docs say a glob rule attaches when a matching file "is in context," but they do not specify whether that includes a file the agent is about to *create* at a path nobody has opened. That is why the workspace tree and the layer table live in the always-apply core rule: an agent creating a brand-new file needs to know where it goes before any glob-scoped rule can attach.

If you split these rules further, keep that placement map in the always-apply file.
