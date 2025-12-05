import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/favorites_provider.dart';

/// Reader screen for displaying term HTML content
class TermReaderScreen extends StatefulWidget {
  final Term term;

  const TermReaderScreen({
    super.key,
    required this.term,
  });

  @override
  State<TermReaderScreen> createState() => _TermReaderScreenState();
}

class _TermReaderScreenState extends State<TermReaderScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith('http')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadHtmlContent();
  }

  Future<void> _loadHtmlContent() async {
    try {
      var htmlContent = await rootBundle.loadString(
        'assets/html/${widget.term.htmlFileName}',
      );

      // Add bottom padding
      const bottomPadding = '<div style="height: 80px;"></div>';
      if (htmlContent.contains('</body>')) {
        htmlContent = htmlContent.replaceFirst('</body>', '$bottomPadding</body>');
      } else {
        htmlContent = '$htmlContent$bottomPadding';
      }

      await _webViewController.loadHtmlString(
        htmlContent,
        baseUrl: 'about:blank',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה בטעינת התוכן')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.term.title,
          style: const TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'הוסף למועדפים',
            onPressed: _addToFavorites,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              Container(
                color: AppTheme.backgroundColor,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.small(
              heroTag: 'scrollTop',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                _webViewController.runJavaScript(
                  'window.scrollTo({top: 0, behavior: "smooth"})',
                );
              },
              child: const Icon(
                Icons.keyboard_arrow_up,
                color: AppTheme.primaryColor,
              ),
            ),
    );
  }

  Future<void> _addToFavorites() async {
    final favoritesProvider = context.read<FavoritesProvider>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הוסף למועדפים'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.term.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('האם להוסיף מושג זה למועדפים?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {'confirm': true}),
            child: const Text('הוסף'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      await favoritesProvider.addFavorite(
        chapterId: widget.term.id,
        chapterTitle: widget.term.title,
        scrollPosition: 0,
        customTitle: 'מושג: ${widget.term.title}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('נוסף למועדפים'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
