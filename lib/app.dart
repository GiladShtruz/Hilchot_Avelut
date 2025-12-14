import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'providers/favorites_provider.dart';
import 'providers/reading_provider.dart';
import 'providers/terms_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_screen.dart';

/// Main application widget
class AvelutHalachaApp extends StatelessWidget {
  const AvelutHalachaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReadingProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => TermsProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..init(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('he', 'IL'),
        supportedLocales: const [
          Locale('he', 'IL'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const MainScreen(),
      ),
    );
  }
}
