import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../data/chapters_data.dart';
import '../../models/models.dart';
import '../../providers/reading_provider.dart';
import '../../widgets/chapter_list_item.dart';
import '../reader/reader_screen.dart';

/// Home screen displaying the list of chapters
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chapters = ChaptersData.chapters;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('אבלות הלכה'),
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
          ),
          // Resume reading banner
          Consumer<ReadingProvider>(
            builder: (context, readingProvider, child) {
              if (!readingProvider.hasSavedPosition) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              final savedPosition = readingProvider.savedPosition!;
              final chapter = ChaptersData.getChapterById(savedPosition.chapterId);
              if (chapter == null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverToBoxAdapter(
                child: _buildResumeCard(context, chapter, savedPosition.scrollPosition),
              );
            },
          ),
          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'תוכן הספר',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          // Chapters list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final chapter = chapters[index];
                return Consumer<ReadingProvider>(
                  builder: (context, readingProvider, child) {
                    final hasProgress = readingProvider.hasChapterPosition(chapter.id);
                    return ChapterListItem(
                      chapter: chapter,
                      showDivider: index < chapters.length - 1,
                      hasProgress: hasProgress,
                      onTap: () => _openChapter(context, chapter),
                    );
                  },
                );
              },
              childCount: chapters.length,
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
    Chapter chapter,
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
          onTap: () => _openChapter(
            context,
            chapter,
            scrollPosition: scrollPosition,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
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
                        chapter.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios,
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

  void _openChapter(
    BuildContext context,
    Chapter chapter, {
    double? scrollPosition,
  }) {
    final readingProvider = context.read<ReadingProvider>();
    
    // Get saved position for this chapter if no specific position provided
    final savedPosition = scrollPosition ?? 
        readingProvider.getChapterPosition(chapter.id);
    
    readingProvider.openChapter(chapter, scrollPosition: savedPosition);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          chapter: chapter,
          initialScrollPosition: savedPosition,
        ),
      ),
    );
  }
}
