import 'package:flutter/material.dart';

class NoPushAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoPushAnimationMaterialPageRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => Duration.zero; // disable push animation

  @override
  Duration get reverseTransitionDuration =>
      const Duration(milliseconds: 300); // keep default pop animation
}
