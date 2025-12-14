import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/search_service.dart';

/// List item widget for displaying a search result
class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final String query;
  final VoidCallback onTap;

  const SearchResultItem({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (result.type) {
      case SearchResultType.term:
        return Icons.menu_book;
      case SearchResultType.chapter:
        return Icons.folder_outlined;
      case SearchResultType.content:
        return Icons.article;
    }
  }

  String _getTypeLabel() {
    switch (result.type) {
      case SearchResultType.term:
        return 'מושג';
      case SearchResultType.chapter:
        return 'פרק';
      case SearchResultType.content:
        return 'תוכן';
    }
  }

  Color _getTypeColor() {
    switch (result.type) {
      case SearchResultType.term:
        return Colors.purple;
      case SearchResultType.chapter:
        return Colors.orange;
      case SearchResultType.content:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIcon(),
                          size: 14,
                          color: _getTypeColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeLabel(),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getTypeColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: _getTypeColor(),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search result context with highlighted match
              _buildHighlightedText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context) {
    // All types now show highlighting
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: result.contextBefore,
            style: const TextStyle(color: AppTheme.secondaryTextColor),
          ),
          TextSpan(
            text: result.matchedText,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              backgroundColor: Color(0xFFFFF9C4),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: result.contextAfter,
            style: const TextStyle(color: AppTheme.secondaryTextColor),
          ),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
