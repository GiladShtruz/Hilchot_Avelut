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

/// Service for searching through HTML content
class SearchService {
  static SearchService? _instance;
  static SearchService get instance => _instance ??= SearchService._();

  SearchService._();

  // Cache for loaded HTML content
  final Map<String, String> _htmlCache = {};

  /// Load HTML content from assets
  Future<String> _loadHtmlContent(String fileName) async {
    if (_htmlCache.containsKey(fileName)) {
      return _htmlCache[fileName]!;
    }

    try {
      final content = await rootBundle.loadString('assets/html/$fileName');
      _htmlCache[fileName] = content;
      return content;
    } catch (e) {
      return '';
    }
  }

  /// Extract plain text from HTML content
  String _extractTextFromHtml(String html) {
    // Remove script tags and their content
    var text = html.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), '');
    
    // Remove style tags and their content
    text = text.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '');
    
    // Remove all HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    
    // Decode HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    
    // Normalize whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return text;
  }

  /// Search for a query in all chapters
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final results = <SearchResult>[];
    final normalizedQuery = query.trim().toLowerCase();
    final chapters = ChaptersData.chapters;

    for (final chapter in chapters) {
      final htmlContent = await _loadHtmlContent(chapter.htmlFileName);
      if (htmlContent.isEmpty) continue;

      final text = _extractTextFromHtml(htmlContent);
      final normalizedText = text.toLowerCase();

      int startIndex = 0;
      while (true) {
        final matchIndex = normalizedText.indexOf(normalizedQuery, startIndex);
        if (matchIndex == -1) break;

        // Extract context around the match
        const contextLength = 50;
        final contextStart = (matchIndex - contextLength).clamp(0, text.length);
        final contextEnd =
            (matchIndex + query.length + contextLength).clamp(0, text.length);

        final contextBefore = text.substring(contextStart, matchIndex);
        final matchedText = text.substring(matchIndex, matchIndex + query.length);
        final contextAfter =
            text.substring(matchIndex + query.length, contextEnd);

        results.add(SearchResult(
          chapter: chapter,
          matchedText: matchedText,
          contextBefore: contextStart > 0 ? '...$contextBefore' : contextBefore,
          contextAfter: contextEnd < text.length ? '$contextAfter...' : contextAfter,
          matchIndex: matchIndex,
        ));

        startIndex = matchIndex + query.length;

        // Limit results per chapter
        if (results.where((r) => r.chapter.id == chapter.id).length >= 5) {
          break;
        }
      }
    }

    return results;
  }

  /// Clear the HTML cache
  void clearCache() {
    _htmlCache.clear();
  }

  /// Preload all HTML content for faster searching
  Future<void> preloadContent() async {
    for (final chapter in ChaptersData.chapters) {
      await _loadHtmlContent(chapter.htmlFileName);
    }
  }
}
