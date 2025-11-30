import 'package:flutter/material.dart';
import 'dart:math';

class NeuralNetworkAnimation extends StatefulWidget {
  const NeuralNetworkAnimation({super.key});

  @override
  State<NeuralNetworkAnimation> createState() => _NeuralNetworkAnimationState();
}

class _NeuralNetworkAnimationState extends State<NeuralNetworkAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Neuron> neurons = [];
  List<Connection> connections = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _initializeNeurons();
  }

  void _initializeNeurons() {
    // Create neurons
    for (int i = 0; i < 15; i++) {
      neurons.add(Neuron(
        offset: Offset(
          (i % 5) * 0.2 + 0.1,
          (i ~/ 5) * 0.2 + 0.1,
        ),
        phase: i * 0.3,
      ));
    }
    
    // Create connections
    for (int i = 0; i < neurons.length; i++) {
      for (int j = i + 1; j < neurons.length; j++) {
        if ((neurons[i].offset - neurons[j].offset).distance < 0.3) {
          connections.add(Connection(
            from: neurons[i],
            to: neurons[j],
            phase: (i + j) * 0.1,
          ));
        }
      }
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
        return CustomPaint(
          painter: NeuralNetworkPainter(
            neurons: neurons,
            connections: connections,
            time: _controller.value * 2 * 3.14159,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Neuron {
  final Offset offset;
  final double phase;
  
  Neuron({required this.offset, required this.phase});
}

class Connection {
  final Neuron from;
  final Neuron to;
  final double phase;
  
  Connection({required this.from, required this.to, required this.phase});
}

class NeuralNetworkPainter extends CustomPainter {
  final List<Neuron> neurons;
  final List<Connection> connections;
  final double time;

  NeuralNetworkPainter({
    required this.neurons,
    required this.connections,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final connectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final neuronPaint = Paint()
      ..style = PaintingStyle.fill;

    // Draw connections
    for (final connection in connections) {
      final fromOffset = Offset(
        connection.from.offset.dx * size.width,
        connection.from.offset.dy * size.height,
      );
      final toOffset = Offset(
        connection.to.offset.dx * size.width,
        connection.to.offset.dy * size.height,
      );
      
      final alpha = (0.3 + 0.2 * sin(time + connection.phase)).clamp(0.1, 0.5);
      connectionPaint.color = Color(0xFF00F5FF).withOpacity(alpha);
      
      canvas.drawLine(fromOffset, toOffset, connectionPaint);
    }

    // Draw neurons
    for (final neuron in neurons) {
      final center = Offset(
        neuron.offset.dx * size.width,
        neuron.offset.dy * size.height,
      );
      
      final pulse = 4 + 2 * sin(time + neuron.phase);
      final alpha = (0.6 + 0.4 * sin(time * 2 + neuron.phase)).clamp(0.3, 1.0);
      
      neuronPaint.color = Color(0xFF9D00FF).withOpacity(alpha);
      canvas.drawCircle(center, pulse, neuronPaint);
      
      neuronPaint.color = Color(0xFF00F5FF).withOpacity(alpha * 0.8);
      canvas.drawCircle(center, pulse * 0.6, neuronPaint);
    }
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) {
    return true;
  }
}