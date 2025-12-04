import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../data/chapters_data.dart';

/// Result of a search operation
class SearchResult {
  final Chapter chapter;
  final String matchedText;
  final String contextBefore;
  final String contextAfter;
  final int matchIndex;

  const SearchResult({
    required this.chapter,
    required this.matchedText,
    required this.contextBefore,
    required this.contextAfter,
    required this.matchIndex,
  });

  /// Full context with the match highlighted
  String get fullContext => '$contextBefore$matchedText$contextAfter';
}

/// Cached chapter data for fast searching
class _ChapterSearchData {
  final Chapter chapter;
  final String plainText;

  _ChapterSearchData({
    required this.chapter,
    required this.plainText,
  });
}

/// Service for searching through HTML content
class SearchService {
  static SearchService? _instance;
  static SearchService get instance => _instance ??= SearchService._();

  SearchService._();

  // Cache for processed chapter content (plain text)
  List<_ChapterSearchData>? _cachedChapterData;
  bool _isPreloading = false;

  /// Preload and process all HTML content for instant searching
  Future<void> preloadContent() async {
    if (_cachedChapterData != null || _isPreloading) return;
    _isPreloading = true;

    try {
      final chapters = ChaptersData.chapters;
      final dataList = <_ChapterSearchData>[];

      for (final chapter in chapters) {
        try {
          final htmlContent = await rootBundle.loadString(
            'assets/html/${chapter.htmlFileName}',
          );
          final plainText = _extractTextFromHtml(htmlContent);
          dataList.add(_ChapterSearchData(
            chapter: chapter,
            plainText: plainText,
          ));
        } catch (e) {
          // Skip chapters that fail to load
        }
      }

      _cachedChapterData = dataList;
    } finally {
      _isPreloading = false;
    }
  }

  /// Extract plain text from HTML content (optimized)
  String _extractTextFromHtml(String html) {
    // Remove script tags and their content
    var text = html.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), '');
    
    // Remove style tags and their content
    text = text.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '');
    
    // Remove all HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    
    // Decode common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"');
    
    // Normalize whitespace (single pass)
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return text;
  }

  /// Search for a query in all chapters (fast, uses cached data)
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // Ensure content is preloaded
    if (_cachedChapterData == null) {
      await preloadContent();
    }

    if (_cachedChapterData == null || _cachedChapterData!.isEmpty) {
      return [];
    }

    // Run search in isolate for large content
    final results = await compute(
      _performSearch,
      _SearchParams(
        query: query.trim(),
        chapterData: _cachedChapterData!,
      ),
    );

    return results;
  }

  /// Clear the cache
  void clearCache() {
    _cachedChapterData = null;
  }
}

/// Parameters for isolate search
class _SearchParams {
  final String query;
  final List<_ChapterSearchData> chapterData;

  _SearchParams({
    required this.query,
    required this.chapterData,
  });
}

/// Perform search in isolate (runs on separate thread)
List<SearchResult> _performSearch(_SearchParams params) {
  final results = <SearchResult>[];
  final normalizedQuery = params.query.toLowerCase();
  const contextLength = 50;
  const maxResultsPerChapter = 5;
  const maxTotalResults = 50;

  for (final data in params.chapterData) {
    final normalizedText = data.plainText.toLowerCase();
    final text = data.plainText;
    int chapterResultCount = 0;

    int startIndex = 0;
    while (chapterResultCount < maxResultsPerChapter && 
           results.length < maxTotalResults) {
      final matchIndex = normalizedText.indexOf(normalizedQuery, startIndex);
      if (matchIndex == -1) break;

      // Extract context around the match
      final contextStart = (matchIndex - contextLength).clamp(0, text.length);
      final contextEnd =
          (matchIndex + params.query.length + contextLength).clamp(0, text.length);

      final contextBefore = text.substring(contextStart, matchIndex);
      final matchedText = text.substring(matchIndex, matchIndex + params.query.length);
      final contextAfter =
          text.substring(matchIndex + params.query.length, contextEnd);

      results.add(SearchResult(
        chapter: data.chapter,
        matchedText: matchedText,
        contextBefore: contextStart > 0 ? '...$contextBefore' : contextBefore,
        contextAfter: contextEnd < text.length ? '$contextAfter...' : contextAfter,
        matchIndex: matchIndex,
      ));

      startIndex = matchIndex + params.query.length;
      chapterResultCount++;
    }

    if (results.length >= maxTotalResults) break;
  }

  return results;
}
