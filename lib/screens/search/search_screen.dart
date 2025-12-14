import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/reading_provider.dart';
import '../../providers/terms_provider.dart';
import '../../services/search_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/search_result_item.dart';
import '../reader/reader_screen.dart';
import '../glossary/term_reader_screen.dart';

/// Search screen for searching through all content
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService.instance;

  List<SearchResult> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _searchService.search(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('חיפוש'),
      ),
      body: Column(
        children: [
          // Search input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'חפש בספר...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
          // Results
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'מחפש...');
    }

    if (!_hasSearched) {
      return const EmptyState(
        icon: Icons.search,
        title: 'חפש בספר',
        subtitle: 'הקלד מילות חיפוש כדי למצוא תוכן',
      );
    }

    if (_results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'לא נמצאו תוצאות',
        subtitle: 'נסה לחפש עם מילים אחרות',
        action: TextButton(
          onPressed: _clearSearch,
          child: const Text('נקה חיפוש'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'נמצאו ${_results.length} תוצאות',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final result = _results[index];
              return SearchResultItem(
                result: result,
                query: _searchController.text,
                onTap: () => _openResult(result),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openResult(SearchResult result) {
    // Handle term results
    if (result.type == SearchResultType.term && result.term != null) {
      final termsProvider = context.read<TermsProvider>();
      termsProvider.accessTerm(result.term!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TermReaderScreen(term: result.term!),
        ),
      );
      return;
    }

    // Handle chapter/content results
    if (result.subChapter != null) {
      final readingProvider = context.read<ReadingProvider>();
      readingProvider.openSubChapter(result.subChapter!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReaderScreen(
            subChapter: result.subChapter!,
            searchQuery: result.type == SearchResultType.content
                ? _searchController.text
                : null,
          ),
        ),
      );
    }
  }
}
