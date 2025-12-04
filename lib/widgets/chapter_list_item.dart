import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/models.dart';

/// List item widget for displaying a chapter
class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;
  final bool showDivider;
  final bool hasProgress;

  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.onTap,
    this.showDivider = true,
    this.hasProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Chapter number indicator
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: hasProgress 
                          ? AppTheme.accentColor.withOpacity(0.15)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: hasProgress
                          ? const Icon(
                              Icons.bookmark,
                              color: AppTheme.accentColor,
                              size: 22,
                            )
                          : Text(
                              _getHebrewNumber(chapter.order),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Chapter info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chapter.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (hasProgress)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'בקריאה',
                                  style: TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (chapter.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            chapter.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Arrow icon
                  const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: AppTheme.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 76),
      ],
    );
  }

  /// Convert number to Hebrew letter
  String _getHebrewNumber(int number) {
    const hebrewLetters = [
      '', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט',
      'י', 'יא', 'יב', 'יג', 'יד', 'טו', 'טז', 'יז', 'יח', 'יט',
      'כ', 'כא', 'כב', 'כג', 'כד', 'כה', 'כו', 'כז', 'כח', 'כט',
      'ל',
    ];
    if (number > 0 && number < hebrewLetters.length) {
      return hebrewLetters[number];
    }
    return number.toString();
  }
}
