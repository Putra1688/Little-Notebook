import 'package:flutter/material.dart';

class AppGradients {
  static LinearGradient primaryGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primaryContainer,
      ],
    );
  }
  
  static LinearGradient secondaryGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Theme.of(context).colorScheme.secondary,
        Theme.of(context).colorScheme.secondaryContainer,
      ],
    );
  }
  
  static LinearGradient surfaceGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Theme.of(context).colorScheme.surface.withOpacity(0.8),
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
      ],
    );
  }
}