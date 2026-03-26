import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';

// ─── Connectivity status ──────────────────────────────────────────────────────

enum ConnectivityStatus { online, offline, restored }

// ─── Stream provider ──────────────────────────────────────────────────────────

final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// ─── ConnectivityBanner widget ────────────────────────────────────────────────

class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;

  ConnectivityStatus _status = ConnectivityStatus.online;
  bool _visible = false;
  bool _wasOffline = false;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);

    if (!hasConnection) {
      // Went offline
      _dismissTimer?.cancel();
      setState(() {
        _status = ConnectivityStatus.offline;
        _visible = true;
        _wasOffline = true;
      });
      _controller.forward();
    } else if (_wasOffline) {
      // Reconnected
      setState(() {
        _status = ConnectivityStatus.restored;
        _visible = true;
        _wasOffline = false;
      });
      _controller.forward();
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _controller.reverse().then((_) {
            if (mounted) setState(() => _visible = false);
          });
        }
      });
    }
  }

  Color get _bannerColor {
    switch (_status) {
      case ConnectivityStatus.offline:
        return AppTheme.errorColor;
      case ConnectivityStatus.restored:
        return AppTheme.successColor;
      case ConnectivityStatus.online:
        return AppTheme.successColor;
    }
  }

  IconData get _bannerIcon {
    switch (_status) {
      case ConnectivityStatus.offline:
        return Icons.wifi_off_rounded;
      case ConnectivityStatus.restored:
        return Icons.wifi_rounded;
      case ConnectivityStatus.online:
        return Icons.wifi_rounded;
    }
  }

  String get _bannerMessage {
    switch (_status) {
      case ConnectivityStatus.offline:
        return 'No internet connection';
      case ConnectivityStatus.restored:
        return 'Connection restored';
      case ConnectivityStatus.online:
        return 'Connected';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityStreamProvider, (_, next) {
      next.whenData(_handleConnectivityChange);
    });

    if (!_visible) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        color: _bannerColor,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 10,
        ),
        child: Row(
          children: [
            Icon(_bannerIcon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              _bannerMessage,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ConnectivityWrapper convenience widget ───────────────────────────────────
// Wrap your main body content with this to automatically show the banner on top.

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ConnectivityBanner(),
        Expanded(child: child),
      ],
    );
  }
}
