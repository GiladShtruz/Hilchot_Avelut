import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/models.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/settings_provider.dart';

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
  double _currentFontSize = AppConstants.defaultFontSize;
  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsProvider = context.read<SettingsProvider>();
    _currentFontSize = _settingsProvider.fontSize;
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

      // Add font size style
      final fontSizeStyle = '''
      <style>
        body { font-size: ${_currentFontSize}px !important; }
        p, div, span, li, td, th { font-size: inherit !important; }
      </style>
      ''';

      // Add bottom padding and scripts
      const bottomPadding = '<div style="height: 80px;"></div>';
      const scripts = '''
      <script>
        function setFontSize(size) {
          document.body.style.fontSize = size + 'px';
        }
      </script>
      ''';

      if (htmlContent.contains('</head>')) {
        htmlContent = htmlContent.replaceFirst('</head>', '$fontSizeStyle</head>');
      } else if (htmlContent.contains('<body')) {
        htmlContent = htmlContent.replaceFirst('<body', '$fontSizeStyle<body');
      } else {
        htmlContent = '$fontSizeStyle$htmlContent';
      }

      if (htmlContent.contains('</body>')) {
        htmlContent = htmlContent.replaceFirst('</body>', '$bottomPadding$scripts</body>');
      } else {
        htmlContent = '$htmlContent$bottomPadding$scripts';
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

  void _changeFontSize(double delta) async {
    final newSize = (_currentFontSize + delta).clamp(
      AppConstants.minFontSize,
      AppConstants.maxFontSize,
    );
    if (newSize != _currentFontSize) {
      setState(() {
        _currentFontSize = newSize;
      });
      await _settingsProvider.setFontSize(newSize);
      await _webViewController.runJavaScript('setFontSize($newSize)');
    }
  }

  void _showFontSizeDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
              TextButton(
                onPressed: () {
                  _changeFontSize(AppConstants.defaultFontSize - _currentFontSize);
                  setModalState(() {});
                },
                child: const Text('איפוס לברירת מחדל'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
