import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../config/theme.dart';
import '../../services/storage_service.dart';

/// PDF Reader screen with position persistence
class PdfReaderScreen extends StatefulWidget {
  const PdfReaderScreen({super.key});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController? _pdfController;
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 0;
  double _savedScrollOffset = 0;

  static const String _pdfPositionKey = 'pdf_book_position';
  static const String _pdfPageKey = 'pdf_book_page';

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _loadSavedPosition();
  }

  void _loadSavedPosition() {
    final storage = StorageService.instance;
    _savedScrollOffset = storage.getSetting<double>(_pdfPositionKey, defaultValue: 0) ?? 0;
    final savedPage = storage.getSetting<int>(_pdfPageKey, defaultValue: 1) ?? 1;
    _currentPage = savedPage;
  }

  Future<void> _savePosition() async {
    final storage = StorageService.instance;
    await storage.saveSetting(_pdfPageKey, _currentPage);
    if (_pdfController != null) {
      await storage.saveSetting(_pdfPositionKey, _pdfController!.scrollOffset.dy);
    }
  }

  @override
  void dispose() {
    _savePosition();
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ספר הלכות אבלות'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            _savePosition();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.first_page),
            tooltip: 'עבור להתחלה',
            onPressed: () {
              _pdfController?.jumpToPage(1);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.asset(
            'assets/pdf/book.pdf',
            key: _pdfViewerKey,
            controller: _pdfController,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            enableDoubleTapZooming: true,
            enableTextSelection: true,
            onDocumentLoaded: (details) {
              setState(() {
                _isLoading = false;
                _totalPages = details.document.pages.count;
              });
              
              // Jump to saved page after document loads
              Future.delayed(const Duration(milliseconds: 100), () {
                if (_currentPage > 1 && _pdfController != null) {
                  _pdfController!.jumpToPage(_currentPage);
                }
              });
            },
            onDocumentLoadFailed: (details) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('שגיאה בטעינת הקובץ: ${details.error}'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            onPageChanged: (details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
              _savePosition();
            },
          ),
          if (_isLoading)
            Container(
              color: AppTheme.backgroundColor,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 16),
                    Text('טוען את הספר...'),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: !_isLoading
          ? FloatingActionButton.small(
              heroTag: 'pdfGoToPage',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _showGoToPageDialog,
              child: const Icon(
                Icons.bookmark,
                color: AppTheme.primaryColor,
              ),
            )
          : null,
    );
  }

  void _showGoToPageDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('עבור לעמוד'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: 'הכנס מספר עמוד (1-$_totalPages)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                _pdfController?.jumpToPage(page);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('מספר עמוד לא תקין')),
                );
              }
            },
            child: const Text('עבור'),
          ),
        ],
      ),
    );
  }
}
