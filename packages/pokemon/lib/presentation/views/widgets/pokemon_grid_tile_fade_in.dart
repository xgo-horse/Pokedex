import 'package:flutter/cupertino.dart';
import 'package:pokemon/presentation/views/widgets/pokemon_grid_fade.dart';

class PokemonGridTileFadeIn extends StatefulWidget {
  const PokemonGridTileFadeIn({super.key, required this.child});

  final Widget child;

  @override
  State<PokemonGridTileFadeIn> createState() => _PokemonGridTileFadeInState();
}

class _PokemonGridTileFadeInState extends State<PokemonGridTileFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kPokemonGridFadeDuration,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: kPokemonGridFadeCurve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
