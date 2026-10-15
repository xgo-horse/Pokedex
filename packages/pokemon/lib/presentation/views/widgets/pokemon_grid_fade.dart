import 'package:flutter/cupertino.dart';

const Duration kPokemonGridFadeDuration = Duration(milliseconds: 450);

const Curve kPokemonGridFadeCurve = Curves.easeInOut;

Widget pokemonGridFadeTransitionBuilder(
  Widget child,
  Animation<double> animation,
) {
  return FadeTransition(opacity: animation, child: child);
}
