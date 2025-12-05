import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../data/terms_data.dart';

/// Provider for managing glossary terms state
class TermsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  bool _isLoading = false;
  List<Term> _sortedTerms = [];

  /// Loading state
  bool get isLoading => _isLoading;

  /// Terms sorted by last accessed (most recent first)
  List<Term> get sortedTerms => _sortedTerms;

  /// Initialize and load term access history
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _loadSortedTerms();

    _isLoading = false;
    notifyListeners();
  }

  /// Load terms sorted by access history
  Future<void> _loadSortedTerms() async {
    final accessHistory = _storage.getTermAccessHistory();
    final allTerms = List<Term>.from(TermsData.terms);

    // Sort by access time (most recent first), then alphabetically for unaccessed
    allTerms.sort((a, b) {
      final aAccess = accessHistory[a.id];
      final bAccess = accessHistory[b.id];

      if (aAccess != null && bAccess != null) {
        return bAccess.compareTo(aAccess); // Most recent first
      } else if (aAccess != null) {
        return -1; // a was accessed, b wasn't
      } else if (bAccess != null) {
        return 1; // b was accessed, a wasn't
      }
      return a.title.compareTo(b.title); // Alphabetical for unaccessed
    });

    _sortedTerms = allTerms;
  }

  /// Record access to a term
  Future<void> accessTerm(Term term) async {
    await _storage.recordTermAccess(term.id);
    await _loadSortedTerms();
    notifyListeners();
  }

  /// Search terms
  List<Term> searchTerms(String query) {
    return TermsData.searchTerms(query);
  }

  /// Get term by ID
  Term? getTermById(String id) {
    return TermsData.getTermById(id);
  }
}
