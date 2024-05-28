import 'package:flutter/material.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late String _userInstanceName;
  String get userInstanceName => _userInstanceName;

  late String _userName;
  String get userName => _userName;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _userInstanceName = await _settingsService.userInstanceName();
    _userName = await _settingsService.userName();

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateUserInstanceName(String? newuserInstanceName) async {
    if (newuserInstanceName == null) return;
    if (newuserInstanceName == _userInstanceName) return;

    _userInstanceName = newuserInstanceName;

    notifyListeners();
    await _settingsService.updateUserInstanceName(newuserInstanceName);
  }

  Future<void> updateUserName(String? newUserName) async {
    if (newUserName == null) return;
    if (newUserName == _userName) return;

    _userName = newUserName;

    notifyListeners();
    await _settingsService.updateUserName(newUserName);
  }
}
