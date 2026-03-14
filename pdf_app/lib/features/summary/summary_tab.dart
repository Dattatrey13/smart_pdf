import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_app/core/theme/app_theme.dart';
import 'package:pdf_app/core/widgets/common_widgets.dart';

class SummaryTab extends StatelessWidget {
  final String? summary;
  final VoidCallback onGenerate;
  final bool isLoading;

  const SummaryTab({
    super.key,
    this.summary,
    required this.onGenerate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: GlowCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Summary',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            Text(
                              'Powered by Claude AI',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.onSurfaceMuted,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Generate button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onGenerate,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: isLoading ? null : AppTheme.primaryGradient,
                  color: isLoading ? AppTheme.surfaceCard : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    else
                      const Icon(Icons.summarize_rounded,
                          color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isLoading ? 'Generating summary...' : 'Generate Summary',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isLoading ? AppTheme.onSurfaceMuted : Colors.white,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Summary content
          Expanded(
            child: summary == null
                ? _EmptySummaryState()
                : _SummaryContent(summary: summary!),
          ),
        ],
      ),
    );
  }
}

class _EmptySummaryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2A2A4A),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.article_outlined,
              color: AppTheme.onSurfaceMuted,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No summary yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap "Generate Summary" to get an\nAI-powered overview of your PDF.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.onSurfaceMuted,
              fontFamily: 'Outfit',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  final String summary;
  const _SummaryContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel(text: 'Summary', icon: Icons.article_rounded),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: summary));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Summary copied!'),
                    backgroundColor: AppTheme.surfaceCard,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A2A4A)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded,
                        size: 14, color: AppTheme.onSurfaceMuted),
                    SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceMuted,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GlowCard(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Text(
                summary,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.onSurface,
                  fontFamily: 'Outfit',
                  height: 1.7,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}