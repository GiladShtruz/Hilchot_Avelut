import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/models.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/reading_provider.dart';
import '../../providers/settings_provider.dart';

/// Reader screen for displaying HTML content
class ReaderScreen extends StatefulWidget {
  final SubChapter subChapter;
  final double initialScrollPosition;
  final String? searchQuery;

  const ReaderScreen({
    super.key,
    required this.subChapter,
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
  double _currentFontSize = AppConstants.defaultFontSize;

  // Save reference to provider to use in dispose
  late ReadingProvider _readingProvider;
  late SettingsProvider _settingsProvider;

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
    _readingProvider = context.read<ReadingProvider>();
    _settingsProvider = context.read<SettingsProvider>();
    _currentFontSize = _settingsProvider.fontSize;
  }

  @override
  void dispose() {
    _readingProvider.saveChapterPosition(
      widget.subChapter.id,
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
      widget.subChapter.id,
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
        'assets/html/${widget.subChapter.htmlFileName}',
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
    const bottomPadding = '''
    <div style="height: 120px;"></div>
    ''';

    final fontSizeStyle = '''
    <style>
      body { font-size: ${_currentFontSize}px !important; }
      p, div, span, li, td, th { font-size: inherit !important; }
    </style>
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

      function setFontSize(size) {
        document.body.style.fontSize = size + 'px';
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

    if (html.contains('</head>')) {
      html = html.replaceFirst('</head>', '$fontSizeStyle</head>');
    } else if (html.contains('<body')) {
      html = html.replaceFirst('<body', '$fontSizeStyle<body');
    }

    if (html.contains('</body>')) {
      return html.replaceFirst('</body>', '$bottomPadding$scripts</body>');
    }
    return '$html$bottomPadding$scripts';
  }

  void _changeFontSize(double delta) async {
    final newSize = (_currentFontSize + delta).clamp(
      AppConstants.minFontSize,
      AppConstants.maxFontSize,
    );
    if (newSize != _currentFontSize) {
      _currentFontSize = newSize;
      await _settingsProvider.setFontSize(newSize);
      await _webViewController.runJavaScript('setFontSize($newSize)');
      // Force a rebuild to update the dialog
      setState(() {});
    }
  }

  void _showFontSizeDialog() {
    final initialFontSize = _currentFontSize;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'גודל כתב',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _currentFontSize > AppConstants.minFontSize
                          ? () {
                              _changeFontSize(-1);
                              setModalState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.text_decrease),
                      iconSize: 32,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${_currentFontSize.toInt()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: _currentFontSize < AppConstants.maxFontSize
                          ? () {
                              _changeFontSize(1);
                              setModalState(() {});
                            }
                          : null,
                      icon: const Icon(Icons.text_increase),
                      iconSize: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  value: _currentFontSize,
                  min: AppConstants.minFontSize,
                  max: AppConstants.maxFontSize,
                  divisions: (AppConstants.maxFontSize - AppConstants.minFontSize).toInt(),
                  label: _currentFontSize.toInt().toString(),
                  onChanged: (value) {
                    final newSize = value.roundToDouble();
                    if (newSize != _currentFontSize) {
                      _changeFontSize(newSize - _currentFontSize);
                      setModalState(() {});
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        _changeFontSize(AppConstants.defaultFontSize - _currentFontSize);
                        setModalState(() {});
                      },
                      child: const Text('איפוס לברירת מחדל'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        // Reload the HTML if font size changed
                        if (_currentFontSize != initialFontSize) {
                          await _reloadHtmlWithNewFontSize();
                        }
                      },
                      child: const Text('אישור'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reloadHtmlWithNewFontSize() async {
    setState(() => _isLoading = true);
    // Mark that we need to restore scroll position after reload
    _hasScrolledToInitial = false;
    await _loadHtmlContent();
  }

  void _onPageLoaded() async {
    setState(() => _isLoading = false);

    // Restore scroll position (either initial or current)
    if (!_hasScrolledToInitial) {
      _hasScrolledToInitial = true;
      final scrollPosition = _currentScrollPosition > 0
          ? _currentScrollPosition
          : widget.initialScrollPosition;

      if (scrollPosition > 0) {
        await Future.delayed(const Duration(milliseconds: 100));
        await _webViewController.runJavaScript(
          'scrollToPosition($scrollPosition)',
        );
      }
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
          widget.subChapter.title,
          style: const TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _saveCurrentPosition();
            Navigator.pop(context);
          },
        ),
        actions: [
          // Scroll to top button
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            tooltip: 'חזרה לראש הדף',
            onPressed: () {
              _webViewController.runJavaScript(
                'window.scrollTo({top: 0, behavior: "smooth"})',
              );
            },
          ),
          // Font size button
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'גודל כתב',
            onPressed: _showFontSizeDialog,
          ),
          // Bookmark button
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
    );
  }

  Future<void> _addToFavorites() async {
    final favoritesProvider = context.read<FavoritesProvider>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddFavoriteDialog(
        chapterTitle: widget.subChapter.title,
      ),
    );

    if (result != null && mounted) {
      await favoritesProvider.addFavorite(
        chapterId: widget.subChapter.id,
        chapterTitle: widget.subChapter.title,
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
