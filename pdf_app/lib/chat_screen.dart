import 'package:flutter/material.dart';
import 'package:pdf_app/features/chat/widgets/chat_bubble.dart';
import 'package:pdf_app/features/chat/widgets/chat_inpute_bar.dart';
import 'api_service.dart';
import 'features/chat/models/message.dart';
import 'core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final ApiService api;

  const ChatScreen({super.key, required this.api});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _loading = false;

  static const List<String> _suggestions = [
    '📋  Summarize the key points',
    '🔍  What are the main findings?',
    '📌  List important dates or numbers',
    '💡  Explain in simple terms',
  ];

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    _controller.clear();

    setState(() {
      _messages.add(Message(role: 'user', text: text));
      _loading = true;
    });

    _scrollToBottom();

    try {
      final answer = await widget.api.askQuestion(text);
      setState(() {
        _messages.add(Message(role: 'assistant', text: answer));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          role: 'assistant',
          text: 'Sorry, something went wrong. Please try again.',
        ));
      });
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages area
        Expanded(
          child: _messages.isEmpty ? _EmptyState(
            suggestions: _suggestions,
            onSuggestion: (s) {
              _controller.text = s.replaceAll(RegExp(r'^[^\s]+\s+'), '');
              _send();
            },
          ) : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (context, i) {
              if (_loading && i == _messages.length) {
                return const TypingIndicator();
              }
              return ChatBubble(
                message: _messages[i],
                isLatest: i == _messages.length - 1,
              );
            },
          ),
        ),
        // Input bar
        ChatInputBar(
          controller: _controller,
          onSend: _send,
          isLoading: _loading,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;

  const _EmptyState({required this.suggestions, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Glowing AI icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ask me anything',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'I\'ve read your PDF. Ask questions, get\nsummaries, or find specific details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceMuted,
              fontFamily: 'Outfit',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SUGGESTED QUESTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceMuted,
                letterSpacing: 1.2,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...suggestions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SuggestionChip(label: s, onTap: () => onSuggestion(s)),
          )),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: _hovered
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? AppTheme.primary.withOpacity(0.4)
                : const Color(0xFF2A2A4A),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppTheme.onSurfaceMuted.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}