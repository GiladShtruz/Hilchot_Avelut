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
              // Chapter title
              Row(
                children: [
                  const Icon(
                    Icons.article,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.chapter.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.primaryColor,
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
