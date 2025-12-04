import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/reading_provider.dart';

/// Reader screen for displaying HTML content
class ReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final double initialScrollPosition;
  final String? searchQuery;

  const ReaderScreen({
    super.key,
    required this.chapter,
    this.initialScrollPosition = 0,
    this.searchQuery,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> with WidgetsBindingObserver {
  late WebViewController _webViewController;
  bool _isLoading = true;
  double _currentScrollPosition = 0;
  bool _hasScrolledToInitial = false;

  // Save reference to provider to use in dispose
  late ReadingProvider _readingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentScrollPosition = widget.initialScrollPosition;
    _initWebView();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to provider here (safe to use in dispose)
    _readingProvider = context.read<ReadingProvider>();
  }

  @override
  void dispose() {
    // Use saved reference instead of context.read
    _readingProvider.saveChapterPosition(
      widget.chapter.id,
      _currentScrollPosition,
    );
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveCurrentPosition();
    }
  }

  void _saveCurrentPosition() {
    _readingProvider.saveChapterPosition(
      widget.chapter.id,
      _currentScrollPosition,
    );
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _onPageLoaded(),
          onNavigationRequest: (request) {
            if (request.url.startsWith('http')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          _handleJsMessage(message.message);
        },
      );

    _loadHtmlContent();
  }

  Future<void> _loadHtmlContent() async {
    try {
      var htmlContent = await rootBundle.loadString(
        'assets/html/${widget.chapter.htmlFileName}',
      );

      htmlContent = _injectScripts(htmlContent);

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

  String _injectScripts(String html) {
    // Add padding at the bottom for FAB and extra space
    const bottomPadding = '''
    <div style="height: 120px;"></div>
    ''';

    final scripts = '''
    <script>
      let scrollTimeout;
      window.addEventListener('scroll', function() {
        clearTimeout(scrollTimeout);
        scrollTimeout = setTimeout(function() {
          FlutterChannel.postMessage(JSON.stringify({
            type: 'scroll',
            position: window.scrollY
          }));
        }, 100);
      });

      function scrollToPosition(position) {
        window.scrollTo({ top: position, behavior: 'instant' });
      }

      function highlightText(query) {
        if (!query) return;
        const escapedQuery = query.replace(/[.*+?^&{}()|[\\]\\\\]/g, '\\\\&');
        const regex = new RegExp('(' + escapedQuery + ')', 'gi');
        const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
        const textNodes = [];
        while (walker.nextNode()) textNodes.push(walker.currentNode);
        
        textNodes.forEach(node => {
          if (regex.test(node.textContent)) {
            const span = document.createElement('span');
            span.innerHTML = node.textContent.replace(regex, '<mark style="background:#FFF9C4;padding:2px;">''' + r'$1' + '''</mark>');
            node.parentNode.replaceChild(span, node);
          }
        });

        const firstMark = document.querySelector('mark');
        if (firstMark) firstMark.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    </script>
    ''';

    if (html.contains('</body>')) {
      return html.replaceFirst('</body>', '$bottomPadding$scripts</body>');
    }
    return '$html$bottomPadding$scripts';
  }

  void _onPageLoaded() async {
    setState(() => _isLoading = false);

    if (!_hasScrolledToInitial && widget.initialScrollPosition > 0) {
      _hasScrolledToInitial = true;
      await Future.delayed(const Duration(milliseconds: 100));
      await _webViewController.runJavaScript(
        'scrollToPosition(${widget.initialScrollPosition})',
      );
    }

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      await _webViewController.runJavaScript(
        'highlightText("${widget.searchQuery}")',
      );
    }
  }

  void _handleJsMessage(String message) {
    try {
      if (message.contains('"type":"scroll"')) {
        final match = RegExp(r'"position":(\d+\.?\d*)').firstMatch(message);
        if (match != null) {
          _currentScrollPosition = double.parse(match.group(1)!);
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapter.title,
          style: const TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            _saveCurrentPosition();
            Navigator.pop(context);
          },
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
      // FAB on the right side (start in RTL)
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    if (_isLoading) return null;

    return FloatingActionButton.small(
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
    );
  }

  Future<void> _addToFavorites() async {
    final favoritesProvider = context.read<FavoritesProvider>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddFavoriteDialog(
        chapterTitle: widget.chapter.title,
      ),
    );

    if (result != null && mounted) {
      await favoritesProvider.addFavorite(
        chapterId: widget.chapter.id,
        chapterTitle: widget.chapter.title,
        scrollPosition: _currentScrollPosition,
        customTitle: result['customTitle'] as String?,
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

class _AddFavoriteDialog extends StatefulWidget {
  final String chapterTitle;

  const _AddFavoriteDialog({required this.chapterTitle});

  @override
  State<_AddFavoriteDialog> createState() => _AddFavoriteDialogState();
}

class _AddFavoriteDialogState extends State<_AddFavoriteDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('הוסף למועדפים'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.chapterTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'שם מותאם (אופציונלי)',
              hintText: 'הכנס שם מותאם אישית',
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ביטול'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'customTitle': _controller.text.trim().isEmpty
                  ? null
                  : _controller.text.trim(),
            });
          },
          child: const Text('שמור'),
        ),
      ],
    );
  }
}
