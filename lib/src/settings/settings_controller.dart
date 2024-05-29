import 'package:flutter/material.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late String _userInstanceName;
  String get userInstanceName => _userInstanceName;

  late String _accessToken;
  String get accessToken => _accessToken;

  late MatchedData _matchedData;
  MatchedData get matchedData => _matchedData;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _userInstanceName = await _settingsService.userInstanceName();
    _accessToken = await _settingsService.accessToken();
    _matchedData = await _settingsService.matchedData();

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

  Future<void> updateAccessToken(String? newAccessToken) async {
    if (newAccessToken == null) return;
    if (newAccessToken == _accessToken) return;

    _accessToken = newAccessToken;

    notifyListeners();
    await _settingsService.updateAccessToken(newAccessToken);
  }

  Future<void> updateMatchedData(MatchedData? newMatchedData) async {
    if (newMatchedData == null) return;
    if (newMatchedData == _matchedData) return;

    _matchedData = newMatchedData;

    notifyListeners();
    await _settingsService.updateMatchedData(newMatchedData);
  }
}
