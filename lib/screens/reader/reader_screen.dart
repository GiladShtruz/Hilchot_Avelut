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

class _ReaderScreenState extends State<ReaderScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  double _currentScrollPosition = 0;
  String? _selectedText;

  @override
  void initState() {
    super.initState();
    _currentScrollPosition = widget.initialScrollPosition;
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _onPageLoaded(),
          onNavigationRequest: (request) {
            // Prevent external navigation
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
      final htmlContent = await rootBundle.loadString(
        'assets/html/${widget.chapter.htmlFileName}',
      );

      // Inject scroll tracking and communication scripts
      final modifiedHtml = _injectScripts(htmlContent);
      
      await _webViewController.loadHtmlString(
        modifiedHtml,
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
    final scripts = '''
    <script>
      // Track scroll position
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

      // Track text selection
      document.addEventListener('selectionchange', function() {
        const selection = window.getSelection();
        if (selection && selection.toString().trim()) {
          FlutterChannel.postMessage(JSON.stringify({
            type: 'selection',
            text: selection.toString().trim()
          }));
        }
      });

      // Function to scroll to position
      function scrollToPosition(position) {
        window.scrollTo({
          top: position,
          behavior: 'instant'
        });
      }

      // Function to highlight search query
      function highlightText(query) {
        if (!query) return;
        
        const walker = document.createTreeWalker(
          document.body,
          NodeFilter.SHOW_TEXT,
          null,
          false
        );

        const textNodes = [];
        while (walker.nextNode()) textNodes.push(walker.currentNode);

        textNodes.forEach(node => {
          const text = node.textContent;
          const index = text.toLowerCase().indexOf(query.toLowerCase());
          if (index >= 0) {
            const span = document.createElement('span');
            span.innerHTML = 
              text.substring(0, index) +
              '<mark style="background-color: #FFF9C4; padding: 2px;">' +
              text.substring(index, index + query.length) +
              '</mark>' +
              text.substring(index + query.length);
            node.parentNode.replaceChild(span, node);
          }
        });

        // Scroll to first highlight
        const firstMark = document.querySelector('mark');
        if (firstMark) {
          firstMark.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      }

      // Get text around current scroll position for preview
      function getTextAtPosition() {
        const elements = document.elementsFromPoint(
          window.innerWidth / 2,
          window.innerHeight / 3
        );
        
        for (const el of elements) {
          if (el.textContent && el.textContent.trim().length > 10) {
            const text = el.textContent.trim().substring(0, 100);
            FlutterChannel.postMessage(JSON.stringify({
              type: 'textPreview',
              text: text
            }));
            return;
          }
        }
      }
    </script>
    ''';

    // Insert scripts before closing body tag
    if (html.contains('</body>')) {
      return html.replaceFirst('</body>', '$scripts</body>');
    } else {
      return '$html$scripts';
    }
  }

  void _onPageLoaded() async {
    setState(() => _isLoading = false);

    // Scroll to initial position
    if (widget.initialScrollPosition > 0) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _webViewController.runJavaScript(
        'scrollToPosition(${widget.initialScrollPosition})',
      );
    }

    // Highlight search query if present
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      await _webViewController.runJavaScript(
        'highlightText("${widget.searchQuery}")',
      );
    }
  }

  void _handleJsMessage(String message) {
    try {
      final data = _parseJson(message);
      
      switch (data['type']) {
        case 'scroll':
          _currentScrollPosition = (data['position'] as num).toDouble();
          context.read<ReadingProvider>().updateScrollPosition(_currentScrollPosition);
          break;
        case 'selection':
          _selectedText = data['text'] as String;
          break;
        case 'textPreview':
          // Used when adding to favorites
          break;
      }
    } catch (e) {
      // Ignore parsing errors
    }
  }

  Map<String, dynamic> _parseJson(String json) {
    // Simple JSON parser for our use case
    final result = <String, dynamic>{};
    final cleaned = json.replaceAll('{', '').replaceAll('}', '');
    final pairs = cleaned.split(',');
    
    for (final pair in pairs) {
      final keyValue = pair.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim().replaceAll('"', '');
        var value = keyValue[1].trim().replaceAll('"', '');
        
        // Try to parse as number
        final numValue = num.tryParse(value);
        result[key] = numValue ?? value;
      }
    }
    
    return result;
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
      body: Stack(
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
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    if (_isLoading) return null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scroll to top
        FloatingActionButton.small(
          heroTag: 'scrollTop',
          backgroundColor: Colors.white,
          onPressed: () {
            _webViewController.runJavaScript('window.scrollTo({top: 0, behavior: "smooth"})');
          },
          child: const Icon(
            Icons.keyboard_arrow_up,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        // Add to favorites
        FloatingActionButton(
          heroTag: 'addFavorite',
          onPressed: _addToFavorites,
          child: const Icon(Icons.bookmark_add),
        ),
      ],
    );
  }

  Future<void> _addToFavorites() async {
    // Get text preview
    await _webViewController.runJavaScript('getTextAtPosition()');
    
    // Small delay to receive the text preview
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    final favoritesProvider = context.read<FavoritesProvider>();
    
    // Show dialog to confirm or add custom name
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddFavoriteDialog(
        chapterTitle: widget.chapter.title,
        textPreview: _selectedText,
      ),
    );

    if (result != null && mounted) {
      await favoritesProvider.addFavorite(
        chapterId: widget.chapter.id,
        chapterTitle: widget.chapter.title,
        scrollPosition: _currentScrollPosition,
        textPreview: _selectedText,
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

/// Dialog for adding a favorite with optional custom title
class _AddFavoriteDialog extends StatefulWidget {
  final String chapterTitle;
  final String? textPreview;

  const _AddFavoriteDialog({
    required this.chapterTitle,
    this.textPreview,
  });

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
          if (widget.textPreview != null) ...[
            const SizedBox(height: 12),
            Text(
              'טקסט נבחר:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.textPreview!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
