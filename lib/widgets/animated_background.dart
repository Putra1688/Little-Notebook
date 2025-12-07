// import 'package:flutter/material.dart';
// import 'neural_network_animation.dart';
// import 'practicle_system.dart';

// class AnimatedBackground extends StatelessWidget {
//   final Widget child;
  
//   const AnimatedBackground({super.key, required this.child});
  
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Deep Space Background
//         Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFF0A0A0F),
//                 Color(0xFF1A0B2E),
//                 Color(0xFF0F1A2F),
//               ],
//             ),
//           ),
//         ),
        
//         // Neural Network Animation
//         const Positioned.fill(
//           child: NeuralNetworkAnimation(),
//         ),
        
//         // Floating Particles
//         const Positioned.fill(
//           child: ParticleSystem(),
//         ),
        
//         // Content
//         child,
//       ],
//     );
//   }
// }