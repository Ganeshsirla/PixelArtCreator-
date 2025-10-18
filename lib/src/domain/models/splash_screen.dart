import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/src/src.dart'; // ADDED THIS IMPORT

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _strokeController;
  late AnimationController _textController;
  late AnimationController _starsController;
  late AnimationController _bgController;
  late AnimationController _splashController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _strokeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    Timer(const Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DrawingPage()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _strokeController.dispose();
    _textController.dispose();
    _starsController.dispose();
    _bgController.dispose();
    _splashController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightGreen.shade200,
                  Colors.lightGreen.shade300,
                  Colors.lightGreen.shade400,
                  Colors.lightGreen.shade500,
                  Colors.lightGreen.shade600,
                  Colors.lightGreen.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(_bgController.value * 2 * math.pi),
              ),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: size,
                  painter: StarsPainter(_starsController.value),
                ),
                CustomPaint(
                  size: size,
                  painter: FloatingItemsPainter(_bgController.value),
                ),
                CustomPaint(
                  size: size,
                  painter: ShootingStarPainter(_bgController.value),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(220, 220),
                            painter: PaintSplashPainter(
                              _splashController.value,
                            ),
                          ),
                          CustomPaint(
                            size: const Size(160, 160),
                            painter: RainbowStrokePainter(
                              _strokeController.value,
                            ),
                          ),
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.lightGreenAccent
                                      .withOpacity(0.4),
                                  blurRadius: 60,
                                  spreadRadius: 40,
                                ),
                              ],
                            ),
                          ),
                          RotationTransition(
                            turns: Tween(
                              begin: -0.05,
                              end: 0.05,
                            ).animate(_logoController),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.9, end: 1.2)
                                  .animate(
                                CurvedAnimation(
                                  parent: _logoController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(3, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.palette_rounded, // ✅ changed logo
                                  size: 90,
                                  color: Colors.lightGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.lightGreenAccent.shade100,
                                Colors.lightGreenAccent.shade200,
                                Colors.lightGreenAccent.shade400,
                                Colors.greenAccent.shade400,
                              ],
                              transform: GradientRotation(
                                _shimmerController.value * 2 * math.pi,
                              ),
                            ).createShader(bounds),
                            child: const Text(
                              "painting pixels",
                              style: TextStyle(
                                fontSize: 46,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ComicNeue',
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "",
                        style: TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Rainbow stroke painter (now light green theme)
class RainbowStrokePainter extends CustomPainter {
  final double progress;
  RainbowStrokePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = SweepGradient(
      colors: [
        Colors.lightGreen.shade200,
        Colors.lightGreen.shade300,
        Colors.lightGreen.shade400,
        Colors.lightGreen.shade500,
        Colors.lightGreen.shade600,
        Colors.lightGreen.shade700,
        Colors.lightGreen.shade200,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final startAngle = -math.pi / 2;
    final sweepAngle = progress * 2 * math.pi;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant RainbowStrokePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class StarsPainter extends CustomPainter {
  final double progress;
  StarsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.lightGreenAccent.withOpacity(0.9);

    for (int i = 0; i < 25; i++) {
      final dx =
          (size.width * ((i * 37 % 100) / 100)) +
              (10 * math.sin(progress * 2 * math.pi + i));
      final dy =
          (size.height * ((i * 53 % 100) / 100)) +
              (10 * math.cos(progress * 2 * math.pi + i));
      canvas.drawCircle(Offset(dx, dy), (i % 3 == 0 ? 3 : 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) => true;
}

class FloatingItemsPainter extends CustomPainter {
  final double progress;
  FloatingItemsPainter(this.progress);

  final icons = ["🎨", "🖌️", "✏️", "🌿", "🍃", "🖍️", "✨"];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < icons.length; i++) {
      final dx =
          size.width * ((i * 23 % 100) / 100) +
              (20 * math.sin(progress * 2 * math.pi + i));
      final dy =
          size.height * ((i * 41 % 100) / 100) +
              (25 * math.cos(progress * 2 * math.pi + i));

      TextPainter tp = TextPainter(
        text: TextSpan(text: icons[i], style: const TextStyle(fontSize: 28)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant FloatingItemsPainter oldDelegate) => true;
}

class ShootingStarPainter extends CustomPainter {
  final double progress;
  ShootingStarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightGreenAccent.withOpacity(0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final dx =
          size.width * ((i * 29 % 100) / 100) + progress * size.width * 0.8;
      final dy =
          size.height * ((i * 17 % 100) / 100) + progress * size.height * 0.3;
      canvas.drawLine(Offset(dx, dy), Offset(dx - 20, dy + 20), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ShootingStarPainter oldDelegate) => true;
}

class PaintSplashPainter extends CustomPainter {
  final double progress;
  PaintSplashPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.lightGreen.shade200,
      Colors.lightGreen.shade300,
      Colors.lightGreen.shade400,
      Colors.lightGreen.shade500,
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final radius = progress * size.width / (3 + i);
      canvas.drawCircle(size.center(Offset.zero), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PaintSplashPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
