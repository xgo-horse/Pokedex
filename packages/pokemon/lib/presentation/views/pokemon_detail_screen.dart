import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokemon/domain/models/pokemon.dart';
import 'package:pokemon/presentation/actions/pokemon_detail_action.dart';
import 'package:pokemon/presentation/intents/pokemon_detail_intent.dart';
import 'package:pokemon/presentation/localization/pokemon_localizations.dart';
import 'package:pokemon/presentation/view_models/pokemon_detail_cubit.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_detail_body.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key, required this.id, this.name});

  final int id;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        LoadPokemonDetailIntent: LoadPokemonDetailAction(id),
        RefreshPokemonDetailIntent: RefreshPokemonDetailAction(id),
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: BlocBuilder<PokemonDetailCubit, LoadState<Pokemon>>(
          builder: (context, state) {
            final title = _titleFor(context, state);
            return CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(largeTitle: Text(title)),
                ..._contentSlivers(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  String _titleFor(BuildContext context, LoadState<Pokemon> state) {
    final resolved = switch (state) {
      LoadSuccess(:final data) => data.name,
      _ => name,
    };
    if (resolved == null || resolved.isEmpty) {
      return context.pokemonStrings.pokemonFallbackTitle;
    }
    return _capitalize(resolved);
  }

  List<Widget> _contentSlivers(
    BuildContext context,
    LoadState<Pokemon> state,
  ) => switch (state) {
    LoadInitial() => const [SliverToBoxAdapter(child: SizedBox.shrink())],
    LoadLoading() => const [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CupertinoActivityIndicator(radius: 14)),
      ),
    ],
    LoadFailure(:final failure) => [
      SliverFillRemaining(
        hasScrollBody: false,
        child: _PokemonDetailErrorView(
          message: context.pokemonStrings.failureMessage(failure),
        ),
      ),
    ],
    LoadSuccess(:final data) => [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(child: PokemonDetailBody(pokemon: data)),
      ),
    ],
  };

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _PokemonDetailErrorView extends StatelessWidget {
  const _PokemonDetailErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final secondaryLabel = CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    );
    final messageStyle = CupertinoTheme.of(
      context,
    ).textTheme.textStyle.copyWith(color: secondaryLabel);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: secondaryLabel,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: messageStyle),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: () =>
                  Actions.invoke(context, const RefreshPokemonDetailIntent()),
              child: Text(context.pokemonStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
