import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// Interactive celebratory particle emitter for sector synchronization (Victory).
///
/// Emits floating luminous photon motes and quantum sparks across the view.
class CelebrationParticles extends StatefulWidget {
  final VoidCallback? onComplete;

  const CelebrationParticles({super.key, this.onComplete});

  @override
  State<CelebrationParticles> createState() => _CelebrationParticlesState();
}

class _CelebrationParticlesState extends State<CelebrationParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_PhotonParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final random = math.Random();
    final colors = [
      GameTheme.cyanAccent,
      GameTheme.blueAccent,
      GameTheme.violetAccent,
      const Color(0xFFFFD700), // Solar Gold
      const Color(0xFF22F5A5), // Bio Matrix Green
    ];

    _particles = List.generate(45, (index) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 120.0 + random.nextDouble() * 260.0;
      final size = 3.5 + random.nextDouble() * 5.5;
      final color = colors[random.nextInt(colors.length)];
      return _PhotonParticle(
        angle: angle,
        speed: speed,
        radius: size,
        color: color,
        spin: (random.nextDouble() - 0.5) * 4.0,
      );
    });

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(
              progress: _controller.value,
              particles: _particles,
            ),
          );
        },
      ),
    );
  }
}

class _PhotonParticle {
  final double angle;
  final double speed;
  final double radius;
  final Color color;
  final double spin;

  const _PhotonParticle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
    required this.spin,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_PhotonParticle> particles;

  _ParticlePainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final paint = Paint()..style = PaintingStyle.fill;

    // Decay factor
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final distance = p.speed * progress;
      final dx = center.dx + math.cos(p.angle) * distance;
      final dy =
          center.dy +
          math.sin(p.angle) * distance +
          (progress * progress * 80.0); // Gravity drift

      paint.color = p.color.withAlpha(
        ((opacity * 0.9) * 255).toInt().clamp(0, 255),
      );

      // Inner particle core
      canvas.drawCircle(
        Offset(dx, dy),
        p.radius * (1.0 - progress * 0.3),
        paint,
      );

      // Outer glow halo
      paint.color = p.color.withAlpha(
        ((opacity * 0.25) * 255).toInt().clamp(0, 255),
      );
      canvas.drawCircle(Offset(dx, dy), p.radius * 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
