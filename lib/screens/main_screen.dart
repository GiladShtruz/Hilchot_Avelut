import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'favorites/favorites_screen.dart';
import 'glossary/glossary_screen.dart';

/// Main screen with bottom navigation bar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    GlossaryScreen(),
    FavoritesScreen(),
  ];

  /// Navigate to a specific tab
  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          // Navigate to home tab first
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                type: BottomNavigationBarType.fixed,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'בית',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search),
                    label: 'חיפוש',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book_outlined),
                    activeIcon: Icon(Icons.menu_book),
                    label: 'מושגים',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark_outline),
                    activeIcon: Icon(Icons.bookmark),
                    label: 'מועדפים',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}