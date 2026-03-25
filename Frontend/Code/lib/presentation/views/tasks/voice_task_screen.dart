import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../data/models/task.dart';
import '../../providers.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../theme.dart';
import '../../../core/utils/haptic_helper.dart';

// ─── Parsed task preview model ────────────────────────────────────────────────

class ParsedTask {
  final String title;
  final String? description;
  final String priority;
  final String? dueDate;

  const ParsedTask({
    required this.title,
    this.description,
    this.priority = 'MEDIUM',
    this.dueDate,
  });

  factory ParsedTask.fromJson(Map<String, dynamic> json) {
    return ParsedTask(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priority: json['priority'] as String? ?? 'MEDIUM',
      dueDate: json['dueDate'] as String? ?? json['due_date'] as String?,
    );
  }
}

// ─── Voice state ──────────────────────────────────────────────────────────────

enum VoicePhase { idle, listening, processing, preview, error, success }

// ─── Helper to show the modal bottom sheet ────────────────────────────────────

Future<bool?> showVoiceTaskSheet(
  BuildContext context, {
  required String projectId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (_) => VoiceTaskSheet(projectId: projectId),
  );
}

// ─── VoiceTaskSheet ───────────────────────────────────────────────────────────

class VoiceTaskSheet extends ConsumerStatefulWidget {
  final String projectId;

  const VoiceTaskSheet({super.key, required this.projectId});

  @override
  ConsumerState<VoiceTaskSheet> createState() => _VoiceTaskSheetState();
}

class _VoiceTaskSheetState extends ConsumerState<VoiceTaskSheet>
    with TickerProviderStateMixin {
  // Speech
  stt.SpeechToText? _speech;
  bool _speechAvailable = false;

  // State
  VoicePhase _phase = VoicePhase.idle;
  String _transcript = '';
  String? _error;
  ParsedTask? _parsedTask;
  bool _isCreating = false;

  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _waveController;
  late Animation<double> _waveAnim;
  late AnimationController _successController;

  // Editable fields for preview
  late TextEditingController _titleController;
  late TextEditingController _descController;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  Future<void> _initSpeech() async {
    try {
      _speech = stt.SpeechToText();
      _speechAvailable = await _speech!.initialize(
        onError: (e) {
          if (mounted) {
            setState(() {
              _phase = VoicePhase.error;
              _error = e.errorMsg;
            });
          }
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == stt.SpeechToText.listeningStatus) {
            if (!_pulseController.isAnimating) {
              _pulseController.repeat(reverse: true);
              _waveController.repeat(reverse: true);
            }
          } else if (status == stt.SpeechToText.doneStatus ||
              status == stt.SpeechToText.notListeningStatus) {
            _pulseController.stop();
            _pulseController.animateTo(1.0);
            _waveController.stop();
          }
        },
      );
    } catch (e) {
      _speechAvailable = false;
      _speech = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _successController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _speech?.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    // Lazy init speech on first tap
    if (_speech == null) {
      await _initSpeech();
    }
    if (!_speechAvailable) {
      setState(() {
        _phase = VoicePhase.error;
        _error = 'Speech recognition not available on this device.';
      });
      return;
    }
    setState(() {
      _phase = VoicePhase.listening;
      _transcript = '';
      _error = null;
      _parsedTask = null;
    });
    await _speech?.listen(
      onResult: (result) {
        setState(() {
          _transcript = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> _stopListening() async {
    await _speech?.stop();
    _pulseController.stop();
    _waveController.stop();
    if (_transcript.isEmpty) {
      setState(() => _phase = VoicePhase.idle);
    }
    // else user can tap "Process with AI"
    setState(() {
      if (_phase == VoicePhase.listening) _phase = VoicePhase.idle;
    });
  }

  Future<void> _processWithAI() async {
    if (_transcript.isEmpty) return;
    setState(() => _phase = VoicePhase.processing);

    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.parseTask(_transcript, widget.projectId);
      final parsed = ParsedTask.fromJson(result);
      _titleController.text = parsed.title;
      _descController.text = parsed.description ?? '';
      _priority = TaskPriority.fromString(parsed.priority);
      setState(() {
        _parsedTask = parsed;
        _phase = VoicePhase.preview;
      });
    } catch (e) {
      setState(() {
        _phase = VoicePhase.error;
        _error = 'AI processing failed: $e';
      });
    }
  }

  Future<void> _confirmTask() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isCreating = true);
    try {
      final taskService = ref.read(taskServiceProvider);
      await taskService.createTask(
        widget.projectId,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        priority: _priority.value,
        dueDate: _parsedTask?.dueDate,
      );
      if (mounted) {
        Haptic.heavy();
        setState(() {
          _isCreating = false;
          _phase = VoicePhase.success;
        });
        _successController.forward(from: 0);
        // Refresh the task list
        ref.read(taskViewModelProvider.notifier).loadTasks(widget.projectId);
        // Auto-pop after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
        _error = 'Failed to create task: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(isDark),
          _buildHeader(isDark),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: _buildPhaseContent(isDark),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.borderPrimary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Voice Task',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: context.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseContent(bool isDark) {
    switch (_phase) {
      case VoicePhase.idle:
      case VoicePhase.listening:
        return _buildListeningView(isDark);
      case VoicePhase.processing:
        return _buildProcessingView(isDark);
      case VoicePhase.preview:
        return _buildPreviewView(isDark);
      case VoicePhase.error:
        return _buildErrorView(isDark);
      case VoicePhase.success:
        return _buildSuccessView();
    }
  }

  // ─── Listening view ─────────────────────────────────────────────────────────

  Widget _buildListeningView(bool isDark) {
    final isListening = _phase == VoicePhase.listening;
    final micColor = isListening ? AppTheme.errorColor : AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Mic button with pulse
          GestureDetector(
            onTap: isListening ? _stopListening : _startListening,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: isListening ? _pulseAnim.value : 1.0,
                child: child,
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isListening
                      ? AppTheme.errorGradient
                      : AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: micColor.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isListening ? 'Listening... tap to stop' : 'Tap mic to speak',
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Animated waveform (visible only while listening)
          if (isListening) ...[
            const SizedBox(height: 20),
            _buildWaveform(isDark),
          ],
          // Transcript
          if (_transcript.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkCardAlt
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderPrimary),
              ),
              child: Text(
                _transcript,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textPrimaryColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _processWithAI,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Process with AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildWaveform(bool isDark) {
    return AnimatedBuilder(
      animation: _waveAnim,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(12, (i) {
            final t = (_waveAnim.value + i * 0.08) % 1.0;
            final h = 8.0 + 22.0 * (0.5 + 0.5 * _sinApprox(t * 3.14159 * 2));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                width: 4,
                height: h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _sinApprox(double x) {
    // Simple sin approximation using Dart's math is fine, but avoid import
    // x in [0, 2pi]: use 4*x/pi - 4*x^2/pi^2 polynomial
    const pi = 3.14159265;
    final normalized = x % (2 * pi);
    if (normalized <= pi) {
      return (4 * normalized / pi) - (4 * normalized * normalized / (pi * pi));
    } else {
      final y = normalized - pi;
      return -((4 * y / pi) - (4 * y * y / (pi * pi)));
    }
  }

  // ─── Processing view ────────────────────────────────────────────────────────

  Widget _buildProcessingView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing with AI...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Extracting task details from your voice',
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Preview view ────────────────────────────────────────────────────────────

  Widget _buildPreviewView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: AppTheme.successColor),
                    SizedBox(width: 4),
                    Text(
                      'AI Parsed',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _phase = VoicePhase.idle;
                  _transcript = '';
                  _parsedTask = null;
                }),
                child: Text(
                  'Redo',
                  style: TextStyle(color: context.textSecondaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: TextStyle(
              color: context.textPrimaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              labelText: 'Task Title',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            style: TextStyle(color: context.textPrimaryColor, fontSize: 14),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Priority',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: TaskPriority.values.map((p) {
              final isSelected = _priority == p;
              final color = AppTheme.priorityColor(p.value);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: p != TaskPriority.critical ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : isDark
                                ? AppTheme.darkCardAlt
                                : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? color.withValues(alpha: 0.4)
                              : context.borderPrimary,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? color
                                  : context.textSecondaryColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkCardAlt
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderPrimary),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: context.textSecondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _isCreating ? null : _confirmTask,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _isCreating
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.4),
                                AppTheme.secondaryColor.withValues(alpha: 0.4),
                              ],
                            )
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isCreating
                          ? []
                          : AppTheme.glowShadow(AppTheme.primaryColor),
                    ),
                    child: Center(
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Confirm Task',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Success view ─────────────────────────────────────────────────────────────

  Widget _buildSuccessView() {
    final scaleAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    final fadeAnim = CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          ScaleTransition(
            scale: scaleAnim,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successColor,
              ),
              child: FadeTransition(
                opacity: fadeAnim,
                child: const Icon(
                  Icons.check_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: fadeAnim,
            child: Text(
              'Task Created!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error view ──────────────────────────────────────────────────────────────

  Widget _buildErrorView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.textPrimaryColor,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() {
              _phase = VoicePhase.idle;
              _error = null;
              _transcript = '';
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
