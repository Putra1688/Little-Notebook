import 'package:flutter/material.dart';
import 'dart:ui';
import '../themes/app_colors.dart';
import '../themes/app_shadows.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsets padding;
  
  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.glassWhite.withOpacity(0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassWhite.withOpacity(0.1),
            AppColors.glassPurple.withOpacity(0.05),
          ],
        ),
        boxShadow: AppShadows.neonGlow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}