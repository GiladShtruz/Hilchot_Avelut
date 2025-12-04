import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../data/chapters_data.dart';
import '../../models/models.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/reading_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/favorite_list_item.dart';
import '../reader/reader_screen.dart';

/// Favorites screen displaying saved bookmarks
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מועדפים'),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
              if (provider.favorites.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'מחק הכל',
                onPressed: () => _showClearAllDialog(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.isLoading) {
            return const LoadingIndicator(message: 'טוען מועדפים...');
          }

          if (favoritesProvider.favorites.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: 'אין מועדפים',
              subtitle: 'הוסף מועדפים על ידי לחיצה על כפתור הסימניה בזמן קריאה',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: favoritesProvider.favorites.length,
            itemBuilder: (context, index) {
              final favorite = favoritesProvider.favorites[index];
              return FavoriteListItem(
                favorite: favorite,
                onTap: () => _openFavorite(context, favorite),
                onDelete: () => _deleteFavorite(context, favorite),
                onEdit: () => _editFavorite(context, favorite),
              );
            },
          );
        },
      ),
    );
  }

  void _openFavorite(BuildContext context, Favorite favorite) {
    final subChapter = ChaptersData.getSubChapterById(favorite.chapterId);
    if (subChapter == null) return;

    final readingProvider = context.read<ReadingProvider>();
    readingProvider.openSubChapter(subChapter, scrollPosition: favorite.scrollPosition);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          subChapter: subChapter,
          initialScrollPosition: favorite.scrollPosition,
        ),
      ),
    );
  }

  void _deleteFavorite(BuildContext context, Favorite favorite) {
    final favoritesProvider = context.read<FavoritesProvider>();
    favoritesProvider.removeFavorite(favorite.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('המועדף נמחק'),
        action: SnackBarAction(
          label: 'בטל',
          onPressed: () {
            favoritesProvider.addFavorite(
              chapterId: favorite.chapterId,
              chapterTitle: favorite.chapterTitle,
              scrollPosition: favorite.scrollPosition,
              textPreview: favorite.textPreview,
              customTitle: favorite.customTitle,
            );
          },
        ),
      ),
    );
  }

  void _editFavorite(BuildContext context, Favorite favorite) {
    final controller = TextEditingController(text: favorite.customTitle ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ערוך שם מועדף'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'הכנס שם מותאם אישית',
          ),
          textDirection: TextDirection.rtl,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                context
                    .read<FavoritesProvider>()
                    .updateFavoriteTitle(favorite.id, newTitle);
              }
              Navigator.pop(context);
            },
            child: const Text('שמור'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת כל המועדפים'),
        content: const Text('האם אתה בטוח שברצונך למחוק את כל המועדפים?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('כל המועדפים נמחקו')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('מחק הכל'),
          ),
        ],
      ),
    );
  }
}
