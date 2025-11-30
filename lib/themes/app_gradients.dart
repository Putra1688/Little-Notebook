import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const LinearGradient cosmicHorizon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.deepSpace, AppColors.cosmicPurple, AppColors.nebulaBlue],
  );
  
  static const LinearGradient neonCyber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryNeon, AppColors.secondaryNeon],
  );
  
  static const LinearGradient glassEffect = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.glassWhite, AppColors.glassPurple],
  );
  
  static const RadialGradient hologram = RadialGradient(
    center: Alignment.center,
    radius: 1.5,
    colors: [
      AppColors.primaryNeon,
      AppColors.secondaryNeon,
      Colors.transparent,
    ],
  );
}