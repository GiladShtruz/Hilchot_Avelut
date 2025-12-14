import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/terms_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import 'term_reader_screen.dart';

/// Glossary screen displaying list of terms
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Term> _searchResults = [];
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
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final termsProvider = context.read<TermsProvider>();
      setState(() {
        _isSearching = true;
        _searchResults = termsProvider.searchTerms(query);
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מילון מושגים'),
      ),
      body: Column(
        children: [
          // Search bar
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
                hintText: 'חפש מושג...',
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
          // Content
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildTermsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final term = _searchResults[index];
        return _TermListItem(
          term: term,
          onTap: () => _openTerm(term),
        );
      },
    );
  }

  Widget _buildTermsList() {
    return Consumer<TermsProvider>(
      builder: (context, termsProvider, child) {
        if (termsProvider.isLoading) {
          return const LoadingIndicator(message: 'טוען מושגים...');
        }

        if (termsProvider.sortedTerms.isEmpty) {
          return const EmptyState(
            icon: Icons.menu_book,
            title: 'אין מושגים',
            subtitle: 'מילון המושגים ריק',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: termsProvider.sortedTerms.length,
          itemBuilder: (context, index) {
            final term = termsProvider.sortedTerms[index];
            return _TermListItem(
              term: term,
              onTap: () => _openTerm(term),
            );
          },
        );
      },
    );
  }

  void _openTerm(Term term) {
    // Record access
    context.read<TermsProvider>().accessTerm(term);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TermReaderScreen(term: term),
      ),
    );
  }
}

/// List item widget for displaying a term
class _TermListItem extends StatelessWidget {
  final Term term;
  final VoidCallback onTap;

  const _TermListItem({
    required this.term,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_stories,
                    color: AppTheme.accentColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      term.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (term.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        term.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
