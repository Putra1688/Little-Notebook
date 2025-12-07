// import 'package:flutter/material.dart';
// import '../themes/app_colors.dart';
// import '../themes/app_gradients.dart';

// class HolographicButton extends StatefulWidget {
//   final VoidCallback onPressed;
//   final Widget child;
//   final double size;
//   final Gradient? gradient;
  
//   const HolographicButton({
//     super.key,
//     required this.onPressed,
//     required this.child,
//     this.size = 56,
//     this.gradient,
//   });

//   @override
//   State<HolographicButton> createState() => _HolographicButtonState();
// }

// class _HolographicButtonState extends State<HolographicButton> 
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
    
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
    
//     _glowAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _onTapDown(TapDownDetails details) {
//     _animationController.forward();
//   }

//   void _onTapUp(TapUpDetails details) {
//     _animationController.reverse();
//     widget.onPressed();
//   }

//   void _onTapCancel() {
//     _animationController.reverse();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: widget.size,
//             height: widget.size,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: widget.gradient ?? AppGradients.neonCyber,
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primaryNeon.withOpacity(0.6 * _glowAnimation.value),
//                   blurRadius: 20 * _glowAnimation.value,
//                   spreadRadius: 5 * _glowAnimation.value,
//                 ),
//                 BoxShadow(
//                   color: AppColors.secondaryNeon.withOpacity(0.4 * _glowAnimation.value),
//                   blurRadius: 30 * _glowAnimation.value,
//                   spreadRadius: 8 * _glowAnimation.value,
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTapDown: _onTapDown,
//                 onTapUp: _onTapUp,
//                 onTapCancel: _onTapCancel,
//                 borderRadius: BorderRadius.circular(widget.size),
//                 child: Center(
//                   child: DefaultTextStyle.merge(
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     child: widget.child,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }