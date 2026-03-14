import 'package:flutter/material.dart';
import 'package:pdf_app/core/widgets/common_widgets.dart';
import 'package:pdf_app/core/theme/app_theme.dart';

class QuickSearchTab extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function(String query) onSearch;

  const QuickSearchTab({super.key, required this.onSearch});

  @override
  State<QuickSearchTab> createState() => _QuickSearchTabState();
}

class _QuickSearchTabState extends State<QuickSearchTab> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  String? _status;
  bool _hasSearched = false;

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _status = null;
      _hasSearched = true;
    });
    try {
      final hits = await widget.onSearch(q);
      setState(() {
        _results = hits;
        _status = '${hits.length} result${hits.length == 1 ? '' : 's'} found';
      });
    } catch (e) {
      setState(() {
        _status = 'Search failed. Try again.';
        _results = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar
          GlowCard(
            padding: EdgeInsets.zero,
            borderRadius: 18,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(Icons.search_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      color: AppTheme.onSurface,
                      fontFamily: 'Outfit',
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search within the document...',
                      hintStyle: TextStyle(
                        color: AppTheme.onSurfaceMuted,
                        fontFamily: 'Outfit',
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: GradientIconButton(
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _loading ? null : _search,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Status bar
          if (_status != null || _loading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (_loading)
                    StatusChip(label: 'Searching...', type: StatusType.loading)
                  else if (_status != null)
                    StatusChip(
                      label: _status!,
                      type: _results.isEmpty
                          ? StatusType.warning
                          : StatusType.success,
                    ),
                ],
              ),
            ),
          // Results
          Expanded(
            child: _loading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Searching document...',
                          style: TextStyle(
                            color: AppTheme.onSurfaceMuted,
                            fontFamily: 'Outfit',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : !_hasSearched
                    ? _SearchEmptyState()
                    : _results.isEmpty
                        ? _NoResultsState(query: _controller.text)
                        : _ResultsList(results: _results),
          ),
        ],
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A2A4A)),
            ),
            child: const Icon(Icons.manage_search_rounded,
                color: AppTheme.onSurfaceMuted, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Search your document',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter a keyword or phrase to find\nrelevant passages instantly.',
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

class _NoResultsState extends StatelessWidget {
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.warning.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.search_off_rounded,
                color: AppTheme.warning, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No matches for "$query"\nTry different keywords.',
            textAlign: TextAlign.center,
            style: const TextStyle(
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

class _ResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: '${results.length} Matches Found',
          icon: Icons.format_list_bulleted_rounded,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final hit = results[i];
              final score = (hit['score'] as num).toDouble();
              final relevance = (score * 100).toInt();
              return _ResultCard(
                index: i + 1,
                text: hit['text'] as String,
                relevance: relevance,
                score: score,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int index;
  final String text;
  final int relevance;
  final double score;

  const _ResultCard({
    required this.index,
    required this.text,
    required this.relevance,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final color = relevance > 70
        ? AppTheme.success
        : relevance > 40
            ? AppTheme.warning
            : AppTheme.onSurfaceMuted;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    '$relevance% match',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(
              text,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppTheme.onSurface,
                fontFamily: 'Outfit',
                height: 1.55,
              ),
            ),
          ),
          // Relevance bar
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            child: LinearProgressIndicator(
              value: score.clamp(0, 1),
              minHeight: 3,
              backgroundColor: const Color(0xFF2A2A4A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}