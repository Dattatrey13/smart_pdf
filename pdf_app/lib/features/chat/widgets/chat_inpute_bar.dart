import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.controller,
    this.onSend,
    this.isLoading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.primary.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _hasText
                        ? AppTheme.primary.withOpacity(0.4)
                        : const Color(0xFF2A2A4A),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isLoading,
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 15,
                    fontFamily: 'Outfit',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ask anything about this PDF...',
                    hintStyle: TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 15,
                      fontFamily: 'Outfit',
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: widget.isLoading ? null : (_) => widget.onSend?.call(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: (_hasText && !widget.isLoading)
                    ? AppTheme.primaryGradient
                    : const LinearGradient(
                        colors: [Color(0xFF2A2A4A), Color(0xFF2A2A4A)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: (_hasText && !widget.isLoading)
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: (widget.isLoading || !_hasText)
                      ? null
                      : widget.onSend,
                  child: widget.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}