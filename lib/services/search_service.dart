import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../data/chapters_data.dart';

/// Result of a search operation
class SearchResult {
  final SubChapter subChapter;
  final String matchedText;
  final String contextBefore;
  final String contextAfter;
  final int matchIndex;

  const SearchResult({
    required this.subChapter,
    required this.matchedText,
    required this.contextBefore,
    required this.contextAfter,
    required this.matchIndex,
  });

  /// Full context with the match highlighted
  String get fullContext => '$contextBefore$matchedText$contextAfter';
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

    final results = await compute(
      _performSearch,
      _SearchParams(
        query: query.trim(),
        data: _cachedData!,
      ),
    );

    return results;
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

  _SearchParams({
    required this.query,
    required this.data,
  });
}

/// Perform search in isolate (runs on separate thread)
List<SearchResult> _performSearch(_SearchParams params) {
  final results = <SearchResult>[];
  final normalizedQuery = params.query.toLowerCase();
  const contextLength = 50;
  const maxResultsPerSubChapter = 5;
  const maxTotalResults = 50;

  for (final data in params.data) {
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
      ));

      startIndex = matchIndex + params.query.length;
      subChapterResultCount++;
    }

    if (results.length >= maxTotalResults) break;
  }

  return results;
}
