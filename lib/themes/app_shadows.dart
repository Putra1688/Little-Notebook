import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  static final List<BoxShadow> neonGlow = [
    BoxShadow(
      color: AppColors.primaryNeon.withOpacity(0.5),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: AppColors.secondaryNeon.withOpacity(0.3),
      blurRadius: 40,
      spreadRadius: 5,
    ),
  ];
  
  static final List<BoxShadow> holographic = [
    BoxShadow(
      color: AppColors.accentNeon.withOpacity(0.4),
      blurRadius: 30,
      spreadRadius: 3,
      offset: const Offset(0, 10),
    ),
  ];
  
  static final List<BoxShadow> deepSpace = [
    BoxShadow(
      color: Colors.black.withOpacity(0.8),
      blurRadius: 50,
      spreadRadius: -10,
    ),
  ];
}