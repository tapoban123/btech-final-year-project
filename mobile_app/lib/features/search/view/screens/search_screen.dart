import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../dashboard/repository/models/document_item.dart';
import '../../../dashboard/view/widgets/batch_action_bar.dart';
import '../../../dashboard/view/widgets/document_card.dart';
import '../../../dashboard/view/widgets/filter_chips_row.dart';

typedef SearchSelectionModeCallback = void Function(
  bool isSelectionMode,
  int selectedCount, {
  VoidCallback? onChat,
  VoidCallback? onShare,
  VoidCallback? onDelete,
  VoidCallback? onClose,
});

class SearchScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;
  final ValueChanged<DocumentItem>? onOpenViewer;
  final String? initialErrorMessage;
  final SearchSelectionModeCallback? onSelectionModeChanged;

  const SearchScreen({
    super.key,
    this.onNavigateToTab,
    this.onOpenViewer,
    this.initialErrorMessage,
    this.onSelectionModeChanged,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController(
    text: 'expedited freight tariffs logistics',
  );
  DocumentFilterCategory _selectedCategory = DocumentFilterCategory.all;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = <String>{};

  late List<DocumentItem> _searchResults;

  static final List<DocumentItem> _initialSearchResults = [
    DocumentItem(
      id: 'search_doc_1',
      title: 'Q3_Financial_Analysis_Report.pdf',
      type: DocumentType.pdf,
      fileSize: '2.4 MB',
      date: AppFormatters.formatDate(DateTime(2026, 10, 12)),
      statusTag: '${AppFormatters.formatPercent(0.94)} match',
      isStatusHighlighted: true,
    ),
    DocumentItem(
      id: 'search_doc_2',
      title: 'Board_Meeting_Memo_Dictation.wav',
      type: DocumentType.audio,
      fileSize: '3.1 MB',
      date: AppFormatters.formatDate(DateTime(2026, 10, 11)),
      statusTag: '${AppFormatters.formatPercent(0.89)} match',
      isStatusHighlighted: true,
      duration: AppFormatters.formatDuration(222),
    ),
    DocumentItem(
      id: 'search_doc_3',
      title: 'Executive_Strategy_Whiteboard.png',
      type: DocumentType.image,
      fileSize: '1.8 MB',
      date: AppFormatters.formatDate(DateTime(2026, 10, 10)),
      statusTag: '${AppFormatters.formatPercent(0.82)} match',
      isStatusHighlighted: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.initialErrorMessage;
    _searchResults = List.from(_initialSearchResults);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<DocumentItem> get _filteredResults {
    final query = _queryController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return [];
    }

    var items = _searchResults;
    if (_selectedCategory != DocumentFilterCategory.all) {
      items = items
          .where((item) => _matchesCategory(item, _selectedCategory))
          .toList();
    }

    // Default mock query and suggestion chips retain full matching set
    if (query == 'expedited freight tariffs logistics' ||
        query == 'financial analysis' ||
        query == 'supplier bottlenecks') {
      return items;
    }

    // Filter by query words in title
    return items.where((item) {
      final text = '${item.title} ${item.date}'.toLowerCase();
      final words = query.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
      return words.any((word) => text.contains(word));
    }).toList();
  }

  bool _matchesCategory(DocumentItem item, DocumentFilterCategory category) {
    if (category == DocumentFilterCategory.all) return true;
    switch (category) {
      case DocumentFilterCategory.reports:
        return item.type == DocumentType.pdf || item.type == DocumentType.docx;
      case DocumentFilterCategory.recordings:
        return item.type == DocumentType.audio;
      case DocumentFilterCategory.diagrams:
        return item.type == DocumentType.image;
      case DocumentFilterCategory.all:
        return true;
    }
  }

  void _toggleSelectionMode(bool enable) {
    setState(() {
      _isSelectionMode = enable;
      if (!enable) {
        _selectedIds.clear();
      }
    });
    _notifySelectionChanged();
  }

  void _toggleDocumentSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    _notifySelectionChanged();
  }

  void _notifySelectionChanged() {
    widget.onSelectionModeChanged?.call(
      _isSelectionMode,
      _selectedIds.length,
      onChat: _handleBatchChat,
      onShare: _handleBatchShare,
      onDelete: _confirmBatchDelete,
      onClose: () => _toggleSelectionMode(false),
    );
  }

  void _handleCardTap(DocumentItem item) {
    if (_isSelectionMode) {
      _toggleDocumentSelection(item.id);
    } else {
      widget.onOpenViewer?.call(item);
    }
  }

  void _handleCardLongPress(DocumentItem item) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedIds.add(item.id);
      });
      _notifySelectionChanged();
    }
  }

  void _handleBatchChat() {
    widget.onNavigateToTab?.call(2);
    _toggleSelectionMode(false);
  }

  void _handleBatchShare() {
    final count = _selectedIds.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing $count file(s)...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmBatchDelete() {
    final count = _selectedIds.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected Files'),
        content: Text(
          'Are you sure you want to delete $count selected file(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _searchResults
                    .removeWhere((item) => _selectedIds.contains(item.id));
                _selectedIds.clear();
                _isSelectionMode = false;
              });
              _notifySelectionChanged();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted $count file(s)'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showItemOptionsModal(BuildContext context, DocumentItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  item.title,
                  style: AppTypography.titleSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: const Text('Chat with this Document'),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onNavigateToTab?.call(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share Document'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing ${item.title}...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Delete Document',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteItem(context, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, DocumentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _searchResults.removeWhere((i) => i.id == item.id);
                _selectedIds.remove(item.id);
              });
              _notifySelectionChanged();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${item.title}"'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      bottomNavigationBar:
          _isSelectionMode && widget.onSelectionModeChanged == null
              ? BatchActionBar(
                  selectedCount: _selectedIds.length,
                  onChatTap: _handleBatchChat,
                  onShareTap: _handleBatchShare,
                  onDeleteTap: _confirmBatchDelete,
                  onCloseTap: () => _toggleSelectionMode(false),
                )
              : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. In-page Header: Semantic Search title (never scrolls)
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
                  const SizedBox(height: 12),

                  // 2. Search Query Input Field (never scrolls)
                  _buildSearchInputField(),
                  const SizedBox(height: 12),

                  // 3. Content Type Filter Bar (never scrolls)
                  FilterChipsRow(
                    selectedCategory: _selectedCategory,
                    onSelected: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Results Header with Select toggle button (never scrolls)
                  _buildResultsHeader(results.length),
                  const SizedBox(height: 12),

                  // 5. Semantic Results List: static if empty, scrollable DocumentCard list if populated
                  Expanded(
                    child: _buildResultCards(context, results),
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
        onChanged: (_) {
          setState(() {
            _errorMessage = null;
          });
        },
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
                      _errorMessage = null;
                      _isSelectionMode = false;
                      _selectedIds.clear();
                    });
                    _notifySelectionChanged();
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

  Widget _buildResultsHeader(int matchCount) {
    if (_errorMessage != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Results',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Search error',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Results',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                AppFormatters.formatNumber(matchCount),
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            _toggleSelectionMode(!_isSelectionMode);
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              _isSelectionMode ? 'Cancel' : 'Select',
              style: AppTypography.labelSm.copyWith(
                color: _isSelectionMode
                    ? AppColors.error
                    : AppColors.primaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCards(
    BuildContext context,
    List<DocumentItem> results,
  ) {
    if (_isLoading) {
      return _buildLoadingDisplay();
    }

    if (_errorMessage != null) {
      return _buildErrorDisplay();
    }

    if (_queryController.text.trim().isEmpty) {
      return _buildEmptyQueryDisplay();
    }

    if (results.isEmpty) {
      return _buildNoResultsDisplay();
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final doc = results[index];
        final isSelected = _selectedIds.contains(doc.id);
        final itemWithSelection = doc.copyWith(isSelected: isSelected);

        return DocumentCard(
          item: itemWithSelection,
          isSelectionMode: _isSelectionMode,
          badgeText: doc.statusTag,
          onTap: () => _handleCardTap(doc),
          onLongPress: () => _handleCardLongPress(doc),
          onToggleSelect: () => _toggleDocumentSelection(doc.id),
          onMoreTap: () => _showItemOptionsModal(context, doc),
        );
      },
    );
  }

  Widget _buildLoadingDisplay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Searching semantic index...',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Search Service Unavailable',
              style: AppTypography.titleSm.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ??
                  'Unable to connect to semantic search service. Please check your network connection and retry.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _retrySearch,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry Search'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryContainer,
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQueryDisplay() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.search_off,
                color: AppColors.outline,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No search query entered',
              style: AppTypography.titleSm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Type a query above to search through documents',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Try quick suggestions:',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('expedited freight tariffs logistics'),
                _buildSuggestionChip('financial analysis'),
                _buildSuggestionChip('supplier bottlenecks'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsDisplay() {
    final hasCategoryFilter = _selectedCategory != DocumentFilterCategory.all;
    final categoryName = _selectedCategory.name.toLowerCase();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.find_in_page_outlined,
                color: AppColors.outline,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: AppTypography.titleSm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasCategoryFilter
                  ? 'No $categoryName matched "${_queryController.text}". Try selecting a different filter category or query.'
                  : 'No documents matched "${_queryController.text}". Try selecting a different filter category or query.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.outline,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasCategoryFilter) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = DocumentFilterCategory.all;
                      });
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('All categories'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryContainer,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _queryController.clear();
                      _isSelectionMode = false;
                      _selectedIds.clear();
                    });
                    _notifySelectionChanged();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear query'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(
        label,
        style: AppTypography.labelSm.copyWith(
          color: AppColors.primaryContainer,
        ),
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      side: const BorderSide(color: AppColors.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: () => _applySuggestion(label),
    );
  }

  void _applySuggestion(String text) {
    setState(() {
      _queryController.text = text;
      _errorMessage = null;
    });
  }

  void _retrySearch() {
    setState(() {
      _isLoading = false;
      _errorMessage = null;
      _isSelectionMode = false;
      _selectedIds.clear();
    });
    _notifySelectionChanged();
  }
}
