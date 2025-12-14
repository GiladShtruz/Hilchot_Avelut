import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

/// Provider for app settings
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  double _fontSize = AppConstants.defaultFontSize;

  double get fontSize => _fontSize;

  /// Initialize settings from storage
  Future<void> init() async {
    _fontSize = _storage.getSetting<double>(
          AppConstants.fontSizeKey,
          defaultValue: AppConstants.defaultFontSize,
        ) ??
        AppConstants.defaultFontSize;
    notifyListeners();
  }

  /// Set font size
  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(AppConstants.minFontSize, AppConstants.maxFontSize);
    await _storage.saveSetting(AppConstants.fontSizeKey, _fontSize);
    notifyListeners();
  }

  /// Increase font size
  Future<void> increaseFontSize() async {
    await setFontSize(_fontSize + 1);
  }

  /// Decrease font size
  Future<void> decreaseFontSize() async {
    await setFontSize(_fontSize - 1);
  }

  /// Reset font size to default
  Future<void> resetFontSize() async {
    await setFontSize(AppConstants.defaultFontSize);
  }
}
