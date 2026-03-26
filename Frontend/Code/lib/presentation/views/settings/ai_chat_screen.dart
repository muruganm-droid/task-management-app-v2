import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/utils/haptic_helper.dart';
import '../../../presentation/providers.dart';
import '../theme.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String role; // 'user' or 'assistant' or 'error'
  final String content;
  final DateTime timestamp;
  final bool isVoice;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isVoice = false,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  // Typing dots animation
  late AnimationController _dotsController;
  late Animation<double> _dotsAnimation;

  // Speech-to-text
  stt.SpeechToText? _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  String _voiceText = '';

  // Text-to-speech
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _ttsEnabled = true;

  // Voice wave animation
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotsAnimation = Tween<double>(begin: 0, end: 1).animate(_dotsController);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSharedInstance(true);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  Future<void> _initSpeech() async {
    try {
      _speech = stt.SpeechToText();
      _speechAvailable = await _speech!.initialize(
        onError: (e) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _voiceText = '';
            });
            _waveController.stop();
          }
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == stt.SpeechToText.doneStatus ||
              status == stt.SpeechToText.notListeningStatus) {
            _waveController.stop();
            if (_isListening && _voiceText.isNotEmpty) {
              _isListening = false;
              _inputController.text = _voiceText;
              _sendMessage(isVoice: true);
            }
            setState(() => _isListening = false);
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
      _speech = null;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _dotsController.dispose();
    _waveController.dispose();
    _tts.stop();
    _speech?.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleVoiceInput() async {
    Haptic.medium();

    if (_isListening) {
      await _speech?.stop();
      _waveController.stop();
      setState(() => _isListening = false);
      if (_voiceText.isNotEmpty) {
        _inputController.text = _voiceText;
        _sendMessage(isVoice: true);
      }
      return;
    }

    if (_speech == null) await _initSpeech();

    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _voiceText = '';
    });
    _waveController.repeat(reverse: true);

    await _speech?.listen(
      onResult: (result) {
        setState(() => _voiceText = result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _speakText(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    Haptic.light();

    // Auto-detect language based on text characters
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final hasChinese = RegExp(r'[\u4e00-\u9fff]').hasMatch(text);
    final hasJapanese = RegExp(r'[\u3040-\u30ff]').hasMatch(text);
    final hasKorean = RegExp(r'[\uac00-\ud7af]').hasMatch(text);
    final hasHindi = RegExp(r'[\u0900-\u097F]').hasMatch(text);
    final hasTamil = RegExp(r'[\u0B80-\u0BFF]').hasMatch(text);

    String lang = 'en-US';
    if (hasArabic) {
      lang = 'ar-SA';
    } else if (hasChinese) {
      lang = 'zh-CN';
    } else if (hasJapanese) {
      lang = 'ja-JP';
    } else if (hasKorean) {
      lang = 'ko-KR';
    } else if (hasHindi) {
      lang = 'hi-IN';
    } else if (hasTamil) {
      lang = 'ta-IN';
    }

    await _tts.setLanguage(lang);
    await _tts.speak(text);
  }

  Future<void> _sendMessage({bool isVoice = false}) async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _inputController.clear();
    _voiceText = '';

    setState(() {
      _messages.add(ChatMessage(
        role: 'user',
        content: text,
        timestamp: DateTime.now(),
        isVoice: isVoice,
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => m.role == 'user' || m.role == 'assistant')
          .take(10)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final response = await ref.read(apiClientProvider).dio.post(
        '/ai/chat',
        data: {'message': text, 'conversationHistory': history},
      );

      final data = response.data;
      final reply = (data is Map && data['reply'] != null)
          ? data['reply'].toString()
          : (data is Map && data['message'] != null)
              ? data['message'].toString()
              : 'I received your message!';

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            role: 'assistant',
            content: reply,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();

        // Auto-speak AI reply if voice input was used and TTS is enabled
        if (isVoice && _ttsEnabled) {
          _speakText(reply);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            role: 'error',
            content: 'Sorry, something went wrong. Please try again.',
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Conversation',
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all messages?',
          style: TextStyle(color: context.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _tts.stop();
              setState(() {
                _messages.clear();
                _isSpeaking = false;
              });
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.surfacePrimary,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: context.textPrimaryColor,
          ),
          onPressed: () {
            _tts.stop();
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Chat with AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  _isListening
                      ? 'Listening...'
                      : _isSpeaking
                          ? 'Speaking...'
                          : _isTyping
                              ? 'Typing...'
                              : 'Online',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isListening
                        ? AppTheme.warningColor
                        : _isSpeaking
                            ? AppTheme.secondaryColor
                            : _isTyping
                                ? AppTheme.primaryColor
                                : AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // TTS toggle
          IconButton(
            icon: Icon(
              _ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _ttsEnabled ? AppTheme.primaryColor : context.textSecondaryColor,
            ),
            onPressed: () {
              Haptic.light();
              setState(() => _ttsEnabled = !_ttsEnabled);
              if (!_ttsEnabled) _tts.stop();
            },
            tooltip: _ttsEnabled ? 'Mute voice' : 'Enable voice',
          ),
          if (_messages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: context.textSecondaryColor),
              onPressed: _clearChat,
              tooltip: 'Clear chat',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: context.borderPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Voice listening indicator
          if (_isListening) _buildListeningBar(isDark),

          // Message list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return _buildTypingIndicator(isDark);
                      }
                      return _buildMessageBubble(_messages[index], isDark);
                    },
                  ),
          ),

          // Input bar
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildListeningBar(bool isDark) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          child: Row(
            children: [
              Icon(Icons.mic_rounded, color: AppTheme.errorColor, size: 20),
              const SizedBox(width: 10),
              // Waveform bars
              ...List.generate(12, (i) {
                final phase = ((_waveController.value * 2 * 3.14159) + i * 0.5);
                final height = 6.0 + 14.0 * ((phase.abs() % 1.0));
                return Container(
                  width: 3,
                  height: height,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _voiceText.isEmpty ? 'Listening...' : _voiceText,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textPrimaryColor,
                    fontStyle: _voiceText.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _toggleVoiceInput,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Stop',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.record_voice_over_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Voice Chat with AI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Speak or type in any language.\nAI will reply with voice too!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondaryColor,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            _buildSuggestionChip('Tell me a joke!'),
            const SizedBox(height: 8),
            _buildSuggestionChip('What are good project ideas?'),
            const SizedBox(height: 8),
            _buildSuggestionChip('Say something in Spanish'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        Haptic.light();
        _inputController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark) {
    final isUser = msg.role == 'user';
    final isError = msg.role == 'error';
    final isAssistant = msg.role == 'assistant';

    final bubbleColor = isError
        ? AppTheme.errorColor.withValues(alpha: 0.1)
        : isUser
            ? AppTheme.primaryColor
            : isDark
                ? AppTheme.darkCardAlt
                : const Color(0xFFF3F4F6);

    final textColor = isError
        ? AppTheme.errorColor
        : isUser
            ? Colors.white
            : context.textPrimaryColor;

    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          );

    final timeStr = DateFormat('h:mm a').format(msg.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                gradient: isError
                    ? AppTheme.errorGradient
                    : AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline_rounded : Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: isAssistant ? () => _speakText(msg.content) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: borderRadius,
                      border: isError
                          ? Border.all(
                              color: AppTheme.errorColor.withValues(alpha: 0.3),
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        if (isAssistant) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.volume_up_rounded,
                                size: 14,
                                color: context.textSecondaryColor.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to listen',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.textSecondaryColor.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (msg.isVoice) ...[
                      Icon(
                        Icons.mic_rounded,
                        size: 10,
                        color: context.textSecondaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: context.textSecondaryColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUser)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(left: 8, bottom: 2),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardAlt : const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _dotsAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i / 3.0;
                    final raw = (_dotsAnimation.value - delay) % 1.0;
                    final t = raw < 0 ? raw + 1.0 : raw;
                    final scale = 0.6 + 0.4 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                    return Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 4.0 : 0),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border(
          top: BorderSide(color: context.borderPrimary),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mic button
          GestureDetector(
            onTap: _isTyping ? null : _toggleVoiceInput,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isListening
                    ? AppTheme.errorColor.withValues(alpha: 0.15)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: _isListening ? AppTheme.errorColor : AppTheme.primaryColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text input
          Expanded(
            child: TextField(
              controller: _inputController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isTyping && !_isListening,
              style: TextStyle(
                color: context.textPrimaryColor,
                fontSize: 15,
              ),
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Type or tap mic to speak...',
                hintStyle: TextStyle(
                  color: context.textSecondaryColor.withValues(alpha: 0.6),
                ),
                filled: true,
                fillColor: isDark
                    ? AppTheme.darkCardAlt
                    : const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: context.borderPrimary,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: _isTyping || _isListening ? null : AppTheme.primaryGradient,
              color: _isTyping || _isListening ? context.borderPrimary : null,
              shape: BoxShape.circle,
              boxShadow: _isTyping || _isListening
                  ? []
                  : [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: IconButton(
              onPressed: _isTyping || _isListening ? null : _sendMessage,
              icon: Icon(
                Icons.send_rounded,
                color: _isTyping || _isListening
                    ? context.textSecondaryColor
                    : Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
