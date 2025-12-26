import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../data/chapters_data.dart';
import '../../models/models.dart';
import '../../providers/reading_provider.dart';
import '../../widgets/chapter_list_item.dart';
import '../reader/reader_screen.dart';
import '../pdf/pdf_reader_screen.dart';
import '../about/about_screen.dart';
import '../main_screen.dart';

/// Home screen displaying the list of chapters
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SearchableItem> _getFilteredItems() {
    final chapters = ChaptersData.chapters;
    final items = <_SearchableItem>[];

    for (final chapter in chapters) {
      // Check if chapter title matches
      final chapterMatches = _searchQuery.isEmpty ||
          chapter.title.contains(_searchQuery) ||
          (chapter.description?.contains(_searchQuery) ?? false);

      // Check sub-chapters
      final matchingSubChapters = chapter.subChapters.where((sub) {
        return _searchQuery.isEmpty || sub.title.contains(_searchQuery);
      }).toList();

      if (chapterMatches || matchingSubChapters.isNotEmpty) {
        items.add(_SearchableItem(
          chapter: chapter,
          matchingSubChapters: _searchQuery.isEmpty
              ? chapter.subChapters
              : matchingSubChapters,
        ));
      }
    }

    return items;
  }


  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with menu
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'הלכות אבלות',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor,
                      Color(0xFF2D4A77),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // הנה החלק החדש שמחליף את ה-IconButton הישן
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Colors.white), // צבע לבן כדי שיראו על הגרדינט
                tooltip: 'תפריט',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onSelected: (value) {
                  if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PdfReaderScreen()),
                    );
                  } else if (value == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
                        SizedBox(width: 10),
                        Text('פתח קובץ ספר'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primaryColor),
                        SizedBox(width: 10),
                        Text('אודות'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Resume reading banner (only when not searching)
          if (!_isSearching)
            Consumer<ReadingProvider>(
              builder: (context, readingProvider, child) {
                if (!readingProvider.hasSavedPosition) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                final savedPosition = readingProvider.savedPosition!;
                final subChapter =
                ChaptersData.getSubChapterById(savedPosition.chapterId);
                if (subChapter == null) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                final parentChapter =
                ChaptersData.getParentChapter(savedPosition.chapterId);

                return SliverToBoxAdapter(
                  child: _buildResumeCard(
                    context,
                    subChapter,
                    parentChapter,
                    savedPosition.scrollPosition,
                  ),
                );
              },
            ),
          // Section header with search icon
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _isSearching
                        ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'חפש בתוכן העניינים...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    )
                        : Text(
                      'תוכן הספר',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (!_isSearching)
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                      ),
                      tooltip: 'חפש בתוכן הספר',
                      onPressed: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          // Search results info
          if (_isSearching && _searchQuery.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'נמצאו ${filteredItems.length} פרקים',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
            ),
          // Empty state for search
          if (_isSearching &&
              _searchQuery.isNotEmpty &&
              filteredItems.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppTheme.secondaryTextColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'לא נמצאו תוצאות',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Chapters list
          if (filteredItems.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = filteredItems[index];
                  return Consumer<ReadingProvider>(
                    builder: (context, readingProvider, child) {
                      return ChapterListItem(
                        chapter: item.chapter,
                        filteredSubChapters: _searchQuery.isNotEmpty
                            ? item.matchingSubChapters
                            : null,
                        hasProgress: (subChapterId) =>
                            readingProvider.hasChapterPosition(subChapterId),
                        onSubChapterTap: (subChapter) =>
                            _openSubChapter(context, subChapter),
                        initiallyExpanded: _searchQuery.isNotEmpty,
                      );
                    },
                  );
                },
                childCount: filteredItems.length,
              ),
            ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(
      BuildContext context,
      SubChapter subChapter,
      Chapter? parentChapter,
      double scrollPosition,
      ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF2D4A77)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSubChapter(
            context,
            subChapter,
            scrollPosition: scrollPosition,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'המשך קריאה',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subChapter.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (parentChapter != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          parentChapter.title,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSubChapter(
      BuildContext context,
      SubChapter subChapter, {
        double? scrollPosition,
      }) {
    // Special handling for glossary redirect (chapter 6)
    if (subChapter.htmlFileName == 'glossary_redirect') {
      // Navigate to glossary tab
      final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
      if (mainScreenState != null) {
        mainScreenState.navigateToTab(2); // Glossary tab index
      }
      return;
    }

    final readingProvider = context.read<ReadingProvider>();

    final savedPosition =
        scrollPosition ?? readingProvider.getChapterPosition(subChapter.id);

    readingProvider.openSubChapter(subChapter, scrollPosition: savedPosition);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          subChapter: subChapter,
          initialScrollPosition: savedPosition,
        ),
      ),
    );
  }
}

/// Helper class for search results
class _SearchableItem {
  final Chapter chapter;
  final List<SubChapter> matchingSubChapters;

  _SearchableItem({
    required this.chapter,
    required this.matchingSubChapters,
  });
}