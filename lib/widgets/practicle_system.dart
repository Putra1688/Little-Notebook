import 'package:flutter/material.dart';

class ParticleSystem extends StatefulWidget {
  const ParticleSystem({super.key});

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    _initializeParticles();
  }

  void _initializeParticles() {
    for (int i = 0; i < 30; i++) {
      particles.add(Particle(
        position: Offset(
          Random.nextDouble(),
          Random.nextDouble(),
        ),
        velocity: Offset(
          (Random.nextDouble() - 0.5) * 0.002,
          (Random.nextDouble() - 0.5) * 0.002,
        ),
        size: Random.nextDouble() * 3 + 1,
        life: Random.nextDouble(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: ParticlePainter(particles: particles),
          size: Size.infinite,
        );
      },
    );
  }

  void _updateParticles() {
    for (final particle in particles) {
      particle.position += particle.velocity;
      particle.life += 0.005;
      
      if (particle.life > 1) {
        particle.position = Offset(
          Random.nextDouble(),
          Random.nextDouble(),
        );
        particle.life = 0;
      }
    }
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  double life;
  
  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.life,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      final center = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );
      
      final alpha = (0.3 * (1 - particle.life)).clamp(0.1, 0.3);
      paint.color = Color(0xFF00F5FF).withOpacity(alpha);
      
      canvas.drawCircle(center, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true;
  }
}

// Helper class since we can't use dart:math in this context
class Random {
  static final _random = _Random();
  
  static double nextDouble() => _random.nextDouble();
}

class _Random {
  int _seed = DateTime.now().millisecondsSinceEpoch;
  
  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}