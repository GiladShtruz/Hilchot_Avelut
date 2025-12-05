import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/models.dart';

/// Expandable list item widget for displaying a chapter with sub-chapters
class ChapterListItem extends StatefulWidget {
  final Chapter chapter;
  final List<SubChapter>? filteredSubChapters;
  final Function(SubChapter) onSubChapterTap;
  final bool Function(String subChapterId) hasProgress;
  final bool initiallyExpanded;

  const ChapterListItem({
    super.key,
    required this.chapter,
    this.filteredSubChapters,
    required this.onSubChapterTap,
    required this.hasProgress,
    this.initiallyExpanded = false,
  });

  @override
  State<ChapterListItem> createState() => _ChapterListItemState();
}

class _ChapterListItemState extends State<ChapterListItem>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _iconRotation;
  late Animation<double> _expandAnimation;

  List<SubChapter> get _subChapters =>
      widget.filteredSubChapters ?? widget.chapter.subChapters;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if any sub-chapter has progress
    final hasAnyProgress = _subChapters
        .any((sub) => widget.hasProgress(sub.id));

    return Column(
      children: [
        // Main chapter header (clickable to expand)
        Material(
          color: _isExpanded 
              ? AppTheme.primaryColor.withOpacity(0.05)
              : Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Chapter icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: hasAnyProgress
                          ? AppTheme.accentColor.withOpacity(0.15)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: hasAnyProgress
                          ? const Icon(
                              Icons.bookmark,
                              color: AppTheme.accentColor,
                              size: 22,
                            )
                          : Text(
                              _getHebrewNumber(widget.chapter.order),
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
                        Text(
                          widget.chapter.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _isExpanded 
                                ? AppTheme.primaryColor 
                                : AppTheme.textColor,
                          ),
                        ),
                        if (widget.chapter.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.chapter.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${_subChapters.length} נושאים',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand/collapse icon
                  RotationTransition(
                    turns: _iconRotation,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Sub-chapters list (animated)
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Column(
            children: _subChapters.map((subChapter) {
              final hasProgress = widget.hasProgress(subChapter.id);
              return _buildSubChapterItem(subChapter, hasProgress);
            }).toList(),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSubChapterItem(SubChapter subChapter, bool hasProgress) {
    return Material(
      color: AppTheme.backgroundColor,
      child: InkWell(
        onTap: () => widget.onSubChapterTap(subChapter),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(right: 60),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: hasProgress 
                    ? AppTheme.accentColor 
                    : AppTheme.dividerColor,
                width: hasProgress ? 3 : 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Sub-chapter indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: hasProgress 
                      ? AppTheme.accentColor 
                      : AppTheme.secondaryTextColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Text(
                  subChapter.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: hasProgress 
                        ? AppTheme.primaryColor 
                        : AppTheme.textColor,
                    fontWeight: hasProgress ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              // Progress indicator
              if (hasProgress)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_back_ios,
                size: 14,
                color: AppTheme.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
