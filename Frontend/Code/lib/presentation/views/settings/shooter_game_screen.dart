import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

// ── Data classes ─────────────────────────────────────────────────────────────

class Enemy {
  double x;
  double y;
  double speed;
  double radius;
  Color color;
  bool isDead;

  Enemy({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.color,
    this.isDead = false,
  });
}

class Bullet {
  double x;
  double y;
  static const double speed = 420.0;
  static const double radius = 5.0;
  bool isActive;

  Bullet({required this.x, required this.y, this.isActive = true});
}

class Star {
  double x;
  double y;
  double speed;
  double size;

  Star({required this.x, required this.y, required this.speed, required this.size});
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life; // 1.0 → 0.0
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    this.life = 1.0,
  });
}

// ── Main screen ───────────────────────────────────────────────────────────────

class ShooterGameScreen extends StatefulWidget {
  const ShooterGameScreen({super.key});

  @override
  State<ShooterGameScreen> createState() => _ShooterGameScreenState();
}

class _ShooterGameScreenState extends State<ShooterGameScreen>
    with SingleTickerProviderStateMixin {
  // Ticker
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;

  // Game dimensions (set in layout)
  double _width = 0;
  double _height = 0;

  // Player
  double _playerX = 0;
  static const double _playerHalfW = 22.0;
  static const double _playerH = 36.0;
  static const double _playerBottomPad = 40.0;

  // Lists
  final List<Enemy> _enemies = [];
  final List<Bullet> _bullets = [];
  final List<Particle> _particles = [];
  final List<Star> _stars = [];

  // Scoring / lives
  int _score = 0;
  int _highScore = 0;
  int _lives = 3;
  bool _isGameOver = false;

  // Enemy spawn timer
  double _spawnTimer = 0.0;
  double _spawnInterval = 1.5; // seconds

  final Random _rng = Random();

  static const List<Color> _enemyColors = [
    AppTheme.errorColor,
    Color(0xFFF97316), // orange
    AppTheme.secondaryColor, // purple
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _highScore = prefs.getInt('shooter_high_score') ?? 0;
      });
    }
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shooter_high_score', _highScore);
  }

  void _initStars() {
    _stars.clear();
    for (int i = 0; i < 70; i++) {
      _stars.add(Star(
        x: _rng.nextDouble() * _width,
        y: _rng.nextDouble() * _height,
        speed: 30 + _rng.nextDouble() * 60,
        size: 0.8 + _rng.nextDouble() * 2.2,
      ));
    }
  }

  void _startGame() {
    _enemies.clear();
    _bullets.clear();
    _particles.clear();
    _score = 0;
    _lives = 3;
    _isGameOver = false;
    _spawnTimer = 0;
    _spawnInterval = 1.5;
    _playerX = _width / 2;
    _lastElapsed = Duration.zero;
    _initStars();

    _ticker?.dispose();
    _ticker = createTicker(_onTick)..start();
    setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (_isGameOver) return;

    final dt = elapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (dt <= 0) return;

    _updateStars(dt);
    _updateBullets(dt);
    _updateEnemies(dt);
    _updateParticles(dt);
    _checkCollisions();
    _spawnTimer += dt;

    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnEnemy();
      // Gradually increase difficulty
      _spawnInterval = max(0.6, _spawnInterval - 0.02);
    }

    setState(() {});
  }

  void _updateStars(double dt) {
    for (final s in _stars) {
      s.y += s.speed * dt;
      if (s.y > _height) {
        s.y = -s.size;
        s.x = _rng.nextDouble() * _width;
      }
    }
  }

  void _updateBullets(double dt) {
    for (final b in _bullets) {
      if (!b.isActive) continue;
      b.y -= Bullet.speed * dt;
      if (b.y < -Bullet.radius) b.isActive = false;
    }
    _bullets.removeWhere((b) => !b.isActive);
  }

  void _updateEnemies(double dt) {
    for (final e in _enemies) {
      if (e.isDead) continue;
      e.y += e.speed * dt;
      if (e.y > _height + e.radius) {
        e.isDead = true;
        _lives--;
        if (_lives <= 0) {
          _lives = 0;
          _gameOver();
        }
      }
    }
    _enemies.removeWhere((e) => e.isDead);
  }

  void _updateParticles(double dt) {
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 180 * dt; // gravity
      p.life -= dt * 2.2;
    }
    _particles.removeWhere((p) => p.life <= 0);
  }

  void _spawnEnemy() {
    final radius = 14.0 + _rng.nextDouble() * 12.0;
    final x = radius + _rng.nextDouble() * (_width - radius * 2);
    final speed = 70.0 + _rng.nextDouble() * 100.0;
    final color = _enemyColors[_rng.nextInt(_enemyColors.length)];

    _enemies.add(Enemy(x: x, y: -radius, speed: speed, radius: radius, color: color));
  }

  void _checkCollisions() {
    for (final b in _bullets) {
      if (!b.isActive) continue;
      for (final e in _enemies) {
        if (e.isDead) continue;
        final dx = b.x - e.x;
        final dy = b.y - e.y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < e.radius + Bullet.radius) {
          b.isActive = false;
          e.isDead = true;
          _score += 10;
          if (_score > _highScore) {
            _highScore = _score;
            _saveHighScore();
          }
          _spawnExplosion(e.x, e.y, e.color);
          break;
        }
      }
    }
  }

  void _spawnExplosion(double x, double y, Color color) {
    for (int i = 0; i < 18; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 60 + _rng.nextDouble() * 160;
      _particles.add(Particle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: color,
      ));
    }
  }

  void _gameOver() {
    _isGameOver = true;
    _ticker?.stop();
    setState(() {});
  }

  void _shoot() {
    if (_isGameOver) return;
    final playerY = _height - _playerBottomPad - _playerH;
    _bullets.add(Bullet(x: _playerX, y: playerY));
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isGameOver) return;
    setState(() {
      _playerX = (_playerX + details.delta.dx).clamp(
        _playerHalfW,
        _width - _playerHalfW,
      );
    });
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Space Shooter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isGameOver && _width > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.favorite,
                        size: 18,
                        color: i < _lives ? Colors.red : Colors.grey.shade800,
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_width == 0 && constraints.maxWidth > 0) {
            _width = constraints.maxWidth;
            _height = constraints.maxHeight;
            _playerX = _width / 2;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _startGame();
            });
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _shoot(),
            onHorizontalDragUpdate: _onDragUpdate,
            onVerticalDragUpdate: (d) {
              // allow vertical drag to avoid swallowing horizontal
            },
            child: Stack(
              children: [
                // Game canvas
                CustomPaint(
                  size: Size(_width, _height),
                  painter: _GamePainter(
                    playerX: _playerX,
                    playerH: _playerH,
                    playerHalfW: _playerHalfW,
                    playerBottomPad: _playerBottomPad,
                    enemies: _enemies,
                    bullets: _bullets,
                    particles: _particles,
                    stars: _stars,
                    height: _height,
                    width: _width,
                  ),
                ),

                // HUD
                if (!_isGameOver)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'SCORE  $_score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'BEST  $_highScore',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Start screen
                if (_width > 0 && _stars.isEmpty)
                  _buildStartScreen(isDark),

                // Game over overlay
                if (_isGameOver)
                  _buildGameOverScreen(isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartScreen(bool isDark) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryColor, size: 64),
            const SizedBox(height: 20),
            const Text(
              'SPACE SHOOTER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap to shoot • Drag to move',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 32),
            _buildActionButton('START GAME', _startGame),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen(bool isDark) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            _buildScoreRow('SCORE', '$_score'),
            const SizedBox(height: 8),
            _buildScoreRow('BEST', '$_highScore'),
            const SizedBox(height: 36),
            _buildActionButton('PLAY AGAIN', _startGame),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Exit',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label  ',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 15,
            letterSpacing: 2,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────────

class _GamePainter extends CustomPainter {
  final double playerX;
  final double playerH;
  final double playerHalfW;
  final double playerBottomPad;
  final List<Enemy> enemies;
  final List<Bullet> bullets;
  final List<Particle> particles;
  final List<Star> stars;
  final double height;
  final double width;

  _GamePainter({
    required this.playerX,
    required this.playerH,
    required this.playerHalfW,
    required this.playerBottomPad,
    required this.enemies,
    required this.bullets,
    required this.particles,
    required this.stars,
    required this.height,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFF050510);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    _drawStars(canvas);
    _drawBullets(canvas);
    _drawEnemies(canvas);
    _drawPlayer(canvas);
    _drawParticles(canvas);
  }

  void _drawStars(Canvas canvas) {
    final paint = Paint();
    for (final s in stars) {
      final opacity = 0.3 + (s.size / 3.0) * 0.7;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(s.x, s.y), s.size / 2, paint);
    }
  }

  void _drawPlayer(Canvas canvas) {
    final py = height - playerBottomPad - playerH;
    final path = Path()
      ..moveTo(playerX, py)
      ..lineTo(playerX - playerHalfW, py + playerH)
      ..lineTo(playerX, py + playerH * 0.75)
      ..lineTo(playerX + playerHalfW, py + playerH)
      ..close();

    // Glow
    final glowPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawPath(path, glowPaint);

    // Body fill (gradient simulation)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(
          playerX - playerHalfW, py, playerHalfW * 2, playerH));
    canvas.drawPath(path, bodyPaint);

    // Engine glow at bottom
    final enginePaint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(playerX, py + playerH + 4), 6, enginePaint);
  }

  void _drawBullets(Canvas canvas) {
    for (final b in bullets) {
      if (!b.isActive) continue;

      // Glow
      final glowPaint = Paint()
        ..color = AppTheme.primaryColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(b.x, b.y), Bullet.radius + 3, glowPaint);

      // Core
      final paint = Paint()..color = const Color(0xFFE0E7FF);
      canvas.drawCircle(Offset(b.x, b.y), Bullet.radius, paint);

      // Trail
      final trailPaint = Paint()
        ..color = AppTheme.primaryColor.withValues(alpha: 0.6)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(b.x, b.y + Bullet.radius), Offset(b.x, b.y + 18), trailPaint);
    }
  }

  void _drawEnemies(Canvas canvas) {
    for (final e in enemies) {
      if (e.isDead) continue;

      // Shadow glow
      final glowPaint = Paint()
        ..color = e.color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(e.x, e.y), e.radius, glowPaint);

      // Body
      final bodyPaint = Paint()..color = e.color;
      canvas.drawCircle(Offset(e.x, e.y), e.radius, bodyPaint);

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3);
      canvas.drawCircle(Offset(e.x - e.radius * 0.25, e.y - e.radius * 0.25),
          e.radius * 0.35, highlightPaint);

      // Inner ring
      final ringPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(e.x, e.y), e.radius * 0.65, ringPaint);
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final alpha = p.life.clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      final size = 3.0 + p.life * 4;
      canvas.drawCircle(Offset(p.x, p.y), size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) => true;
}
