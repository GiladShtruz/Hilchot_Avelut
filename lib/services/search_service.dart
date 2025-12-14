import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../data/chapters_data.dart';
import '../data/terms_data.dart';

/// Type of search result
enum SearchResultType {
  term,       // מושג
  chapter,    // כותרת פרק
  content,    // תוכן טקסט
}

/// Result of a search operation
class SearchResult {
  final SubChapter? subChapter;
  final Term? term;
  final String matchedText;
  final String contextBefore;
  final String contextAfter;
  final int matchIndex;
  final SearchResultType type;

  const SearchResult({
    this.subChapter,
    this.term,
    required this.matchedText,
    required this.contextBefore,
    required this.contextAfter,
    required this.matchIndex,
    required this.type,
  });

  /// Full context with the match highlighted
  String get fullContext => '$contextBefore$matchedText$contextAfter';

  /// Get the title for display
  String get title {
    switch (type) {
      case SearchResultType.term:
        return term?.title ?? '';
      case SearchResultType.chapter:
      case SearchResultType.content:
        return subChapter?.title ?? '';
    }
  }
}

/// Cached sub-chapter data for fast searching
class _SubChapterSearchData {
  final SubChapter subChapter;
  final String plainText;

  _SubChapterSearchData({
    required this.subChapter,
    required this.plainText,
  });
}

/// Service for searching through HTML content
class SearchService {
  static SearchService? _instance;
  static SearchService get instance => _instance ??= SearchService._();

  SearchService._();

  // Cache for processed sub-chapter content (plain text)
  List<_SubChapterSearchData>? _cachedData;
  bool _isPreloading = false;

  /// Preload and process all HTML content for instant searching
  Future<void> preloadContent() async {
    if (_cachedData != null || _isPreloading) return;
    _isPreloading = true;

    try {
      final subChapters = ChaptersData.allSubChapters;
      final dataList = <_SubChapterSearchData>[];

      for (final subChapter in subChapters) {
        try {
          final htmlContent = await rootBundle.loadString(
            'assets/html/${subChapter.htmlFileName}',
          );
          final plainText = _extractTextFromHtml(htmlContent);
          dataList.add(_SubChapterSearchData(
            subChapter: subChapter,
            plainText: plainText,
          ));
        } catch (e) {
          // Skip sub-chapters that fail to load
        }
      }

      _cachedData = dataList;
    } finally {
      _isPreloading = false;
    }
  }

  /// Extract plain text from HTML content (optimized)
  String _extractTextFromHtml(String html) {
    var text = html.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), '');
    text = text.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '');
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  /// Search for a query in all sub-chapters (fast, uses cached data)
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    if (_cachedData == null) {
      await preloadContent();
    }

    if (_cachedData == null || _cachedData!.isEmpty) {
      return [];
    }

    final normalizedQuery = query.trim().toLowerCase();
    final allResults = <SearchResult>[];
    final foundSubChapterIds = <String>{}; // Track found sub-chapters to avoid duplicates
    final foundTermIds = <String>{}; // Track found terms to avoid duplicates

    // 1. חיפוש מושגים (תוצאות ראשונות)
    final termResults = _searchTerms(normalizedQuery);
    for (final result in termResults) {
      if (result.term != null && !foundTermIds.contains(result.term!.id)) {
        foundTermIds.add(result.term!.id);
        allResults.add(result);
      }
    }

    // 2. חיפוש כותרות פרקים
    final chapterResults = _searchChapterTitles(normalizedQuery);
    for (final result in chapterResults) {
      if (result.subChapter != null && !foundSubChapterIds.contains(result.subChapter!.id)) {
        foundSubChapterIds.add(result.subChapter!.id);
        allResults.add(result);
      }
    }

    // 3. חיפוש בתוכן (תוצאות אחרונות) - רק בפרקים שלא נמצאו כבר
    final contentResults = await compute(
      _performSearch,
      _SearchParams(
        query: query.trim(),
        data: _cachedData!,
        excludedSubChapterIds: foundSubChapterIds,
      ),
    );
    allResults.addAll(contentResults);

    return allResults;
  }

  /// Search terms by title
  List<SearchResult> _searchTerms(String normalizedQuery) {
    final results = <SearchResult>[];
    for (final term in TermsData.terms) {
      final termTitleLower = term.title.toLowerCase();
      if (termTitleLower.contains(normalizedQuery)) {
        final matchIndex = termTitleLower.indexOf(normalizedQuery);
        results.add(SearchResult(
          term: term,
          matchedText: term.title.substring(matchIndex, matchIndex + normalizedQuery.length),
          contextBefore: term.title.substring(0, matchIndex),
          contextAfter: term.title.substring(matchIndex + normalizedQuery.length) +
                       (term.description != null ? '\n${term.description}' : ''),
          matchIndex: 0,
          type: SearchResultType.term,
        ));
        if (results.length >= 10) break; // הגבלה של 10 מושגים
      }
    }
    return results;
  }

  /// Search chapter titles
  List<SearchResult> _searchChapterTitles(String normalizedQuery) {
    final results = <SearchResult>[];
    for (final chapter in ChaptersData.chapters) {
      // חיפוש בכותרת הפרק הראשי
      final chapterTitleLower = chapter.title.toLowerCase();
      final chapterDescLower = chapter.description?.toLowerCase() ?? '';

      if (chapterTitleLower.contains(normalizedQuery)) {
        if (chapter.subChapters.isNotEmpty) {
          final matchIndex = chapterTitleLower.indexOf(normalizedQuery);
          results.add(SearchResult(
            subChapter: chapter.subChapters.first,
            matchedText: chapter.title.substring(matchIndex, matchIndex + normalizedQuery.length),
            contextBefore: chapter.title.substring(0, matchIndex),
            contextAfter: chapter.title.substring(matchIndex + normalizedQuery.length) +
                         (chapter.description != null ? '\n${chapter.description}' : ''),
            matchIndex: 0,
            type: SearchResultType.chapter,
          ));
        }
      } else if (chapterDescLower.contains(normalizedQuery) && chapter.description != null) {
        if (chapter.subChapters.isNotEmpty) {
          final matchIndex = chapterDescLower.indexOf(normalizedQuery);
          results.add(SearchResult(
            subChapter: chapter.subChapters.first,
            matchedText: chapter.description!.substring(matchIndex, matchIndex + normalizedQuery.length),
            contextBefore: '${chapter.title}\n${chapter.description!.substring(0, matchIndex)}',
            contextAfter: chapter.description!.substring(matchIndex + normalizedQuery.length),
            matchIndex: 0,
            type: SearchResultType.chapter,
          ));
        }
      }

      // חיפוש בכותרות תתי-פרקים
      for (final subChapter in chapter.subChapters) {
        final subTitleLower = subChapter.title.toLowerCase();
        if (subTitleLower.contains(normalizedQuery)) {
          final matchIndex = subTitleLower.indexOf(normalizedQuery);
          results.add(SearchResult(
            subChapter: subChapter,
            matchedText: subChapter.title.substring(matchIndex, matchIndex + normalizedQuery.length),
            contextBefore: '${chapter.title} > ${subChapter.title.substring(0, matchIndex)}',
            contextAfter: subChapter.title.substring(matchIndex + normalizedQuery.length),
            matchIndex: 0,
            type: SearchResultType.chapter,
          ));
        }
      }
    }
    return results.take(15).toList(); // הגבלה של 15 כותרות
  }

  /// Clear the cache
  void clearCache() {
    _cachedData = null;
  }
}

/// Parameters for isolate search
class _SearchParams {
  final String query;
  final List<_SubChapterSearchData> data;
  final Set<String> excludedSubChapterIds;

  _SearchParams({
    required this.query,
    required this.data,
    this.excludedSubChapterIds = const {},
  });
}

/// Perform search in isolate (runs on separate thread)
List<SearchResult> _performSearch(_SearchParams params) {
  final results = <SearchResult>[];
  final normalizedQuery = params.query.toLowerCase();
  const contextLength = 50;
  const maxResultsPerSubChapter = 5;
  const maxTotalResults = 50;
  final seenSubChapterIds = <String>{};

  for (final data in params.data) {
    // Skip if this sub-chapter was already found in chapter/term search
    if (params.excludedSubChapterIds.contains(data.subChapter.id)) {
      continue;
    }

    // Skip if we already added results for this sub-chapter (avoid duplicates within content)
    if (seenSubChapterIds.contains(data.subChapter.id)) {
      continue;
    }

    final normalizedText = data.plainText.toLowerCase();
    final text = data.plainText;
    int subChapterResultCount = 0;

    int startIndex = 0;
    while (subChapterResultCount < maxResultsPerSubChapter &&
           results.length < maxTotalResults) {
      final matchIndex = normalizedText.indexOf(normalizedQuery, startIndex);
      if (matchIndex == -1) break;

      final contextStart = (matchIndex - contextLength).clamp(0, text.length);
      final contextEnd =
          (matchIndex + params.query.length + contextLength).clamp(0, text.length);

      final contextBefore = text.substring(contextStart, matchIndex);
      final matchedText = text.substring(matchIndex, matchIndex + params.query.length);
      final contextAfter =
          text.substring(matchIndex + params.query.length, contextEnd);

      results.add(SearchResult(
        subChapter: data.subChapter,
        matchedText: matchedText,
        contextBefore: contextStart > 0 ? '...$contextBefore' : contextBefore,
        contextAfter: contextEnd < text.length ? '$contextAfter...' : contextAfter,
        matchIndex: matchIndex,
        type: SearchResultType.content,
      ));

      startIndex = matchIndex + params.query.length;
      subChapterResultCount++;

      // Mark this sub-chapter as seen
      if (subChapterResultCount == 1) {
        seenSubChapterIds.add(data.subChapter.id);
      }
    }

    if (results.length >= maxTotalResults) break;
  }

  return results;
}
