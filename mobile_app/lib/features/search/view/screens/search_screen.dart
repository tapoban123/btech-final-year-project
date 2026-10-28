import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_formatters.dart';

class SearchScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const SearchScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController(
    text: 'expedited freight tariffs logistics',
  );

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. In-page Header: Semantic Search title & filter action (never scrolls)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.saved_search,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Semantic Search',
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.tune,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                        tooltip: 'Search filters',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Search filters & threshold settings'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Search Query Input Field (never scrolls)
                  _buildSearchInputField(),
                  const SizedBox(height: 16),

                  // 3. Results Header (never scrolls)
                  _buildResultsHeader(),
                  const SizedBox(height: 12),

                  // 4. Semantic Results List (only this scrolls using ListView.builder)
                  Expanded(
                    child: _buildResultCards(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSearchInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: TextField(
        controller: _queryController,
        style: AppTypography.bodyMd,
        decoration: InputDecoration(
          hintText: 'Type query or use reference...',
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: _queryController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    size: 18,
                    color: AppColors.outline,
                  ),
                  onPressed: () {
                    setState(() {
                      _queryController.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Search Results',
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryContainer,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD1E4FB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${AppFormatters.formatNumber(3)} semantic matches found',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCards(BuildContext context) {
    if (_queryController.text.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                color: AppColors.outline,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'No search query entered',
                style: AppTypography.titleSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Type a query above to search through documents',
                style: AppTypography.bodySm,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _buildResultCard(
              icon: Icons.picture_as_pdf,
              iconBg: AppColors.surfaceContainerLow,
              iconColor: AppColors.error,
              title: 'Q3_Financial_Analysis_Report.pdf',
              similarityMatch: '${AppFormatters.formatPercent(0.94)} match',
              snippet:
                  '“...operating margins contracted by 2.4% primarily due to expedited freight tariffs and unexpected component re-routing across Q3 logistics...”',
              metaLabel:
                  'Page ${AppFormatters.formatNumber(14)} • ${AppFormatters.formatDate(DateTime(2026, 10, 12))}',
              metaIcon: Icons.calendar_today_outlined,
              onViewInChat: () => widget.onNavigateToTab?.call(2),
            );
          case 1:
            return _buildResultCard(
              icon: Icons.graphic_eq,
              iconBg: AppColors.surfaceContainerLow,
              iconColor: AppColors.secondary,
              title: 'Board_Meeting_Memo_Dictation.wav',
              similarityMatch: '${AppFormatters.formatPercent(0.89)} match',
              snippet:
                  '“...we decided to initiate dual-sourcing immediately to hedge against single-point supplier bottlenecks prior to November delivery targets...”',
              metaLabel:
                  'Audio Segment • ${AppFormatters.formatDuration(222)}',
              metaIcon: Icons.mic_none,
              hasWaveform: true,
              onViewInChat: () => widget.onNavigateToTab?.call(2),
            );
          case 2:
          default:
            return _buildResultCard(
              icon: Icons.image_outlined,
              iconBg: AppColors.surfaceContainerLow,
              iconColor: AppColors.primary,
              title: 'Executive_Strategy_Whiteboard.png',
              similarityMatch: '${AppFormatters.formatPercent(0.82)} match',
              snippet:
                  '[OCR Detected Text] Action Matrix: Tier 1 suppliers under review; escalate alternative quotes to Procurement by Friday...',
              metaLabel: 'Bounding Box #${AppFormatters.formatNumber(4)}',
              metaIcon: Icons.crop_free,
              onViewInChat: () => widget.onNavigateToTab?.call(2),
            );
        }
      },
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String similarityMatch,
    required String snippet,
    required String metaLabel,
    required IconData metaIcon,
    bool hasWaveform = false,
    required VoidCallback onViewInChat,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon, Title, and Match Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 18, color: iconColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.titleSm.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  similarityMatch,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Snippet Text
          Text(
            snippet,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Optional Waveform for audio cards
          if (hasWaveform) ...[
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  for (final h in [8, 14, 10, 18, 6, 12, 16, 9, 14, 8, 12, 6])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Container(
                        width: 2,
                        height: h.toDouble(),
                        decoration: BoxDecoration(
                          color: h > 10
                              ? AppColors.secondary
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${AppFormatters.formatDuration(222)} / ${AppFormatters.formatDuration(738)}',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 10),

          // Bottom Bar: Metadata & View in Chat CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(metaIcon, size: 14, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        metaLabel,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onViewInChat,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.forum_outlined,
                        size: 14,
                        color: AppColors.primaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View in Chat',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
