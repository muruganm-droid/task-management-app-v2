import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

// ─── RocketLoader ─────────────────────────────────────────────────────────────

class RocketLoader extends StatefulWidget {
  const RocketLoader({super.key});

  @override
  State<RocketLoader> createState() => _RocketLoaderState();
}

class _RocketLoaderState extends State<RocketLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _positionAnim = Tween<double>(begin: 0.0, end: -18.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Particle dots (exhaust)
              for (int i = 0; i < 3; i++)
                Positioned(
                  bottom: 4.0 + i * 8.0,
                  child: Opacity(
                    opacity: (((_controller.value + i * 0.15) % 1.0) * 0.8)
                        .clamp(0.0, 1.0),
                    child: Container(
                      width: 5 - i.toDouble(),
                      height: 5 - i.toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor
                            .withValues(alpha: 0.7 - i * 0.2),
                      ),
                    ),
                  ),
                ),
              // Rocket body
              Transform.translate(
                offset: Offset(0, _positionAnim.value),
                child: Opacity(
                  opacity: _fadeAnim.value,
                  child: const Text(
                    '▲',
                    style: TextStyle(
                      fontSize: 32,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── PencilLoader ─────────────────────────────────────────────────────────────

class _PencilPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _PencilPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    const lineCount = 4;
    final lineSpacing = size.height / (lineCount + 1);
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.primaryColor,
    ];

    for (int i = 0; i < lineCount; i++) {
      final y = lineSpacing * (i + 1);
      final delay = i * 0.2;
      final lineProgress = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      final maxWidth = size.width * (0.6 + i * 0.1);
      final lineWidth = maxWidth * lineProgress;

      paint.color = colors[i % colors.length];
      canvas.drawLine(
        Offset(0, y),
        Offset(lineWidth, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PencilPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

class PencilLoader extends StatefulWidget {
  const PencilLoader({super.key});

  @override
  State<PencilLoader> createState() => _PencilLoaderState();
}

class _PencilLoaderState extends State<PencilLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return SizedBox(
          width: 80,
          height: 60,
          child: CustomPaint(
            painter: _PencilPainter(
              progress: _controller.value,
              isDark: isDark,
            ),
          ),
        );
      },
    );
  }
}

// ─── TypingDotsLoader ─────────────────────────────────────────────────────────

class TypingDotsLoader extends StatefulWidget {
  const TypingDotsLoader({super.key});

  @override
  State<TypingDotsLoader> createState() => _TypingDotsLoaderState();
}

class _TypingDotsLoaderState extends State<TypingDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotOffset(int index) {
    final delay = index * 0.25;
    final t = (_controller.value - delay).clamp(0.0, 1.0);
    return -10.0 * math.sin(t * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, _dotOffset(i)),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── CreativeLoader ───────────────────────────────────────────────────────────

class CreativeLoader extends StatefulWidget {
  const CreativeLoader({super.key});

  @override
  State<CreativeLoader> createState() => _CreativeLoaderState();
}

class _CreativeLoaderState extends State<CreativeLoader> {
  late final int _choice;

  @override
  void initState() {
    super.initState();
    _choice = math.Random().nextInt(3);
  }

  Widget _buildLoader() {
    switch (_choice) {
      case 0:
        return const RocketLoader();
      case 1:
        return const PencilLoader();
      default:
        return const TypingDotsLoader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoader(),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
