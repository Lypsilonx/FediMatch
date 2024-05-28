import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchedData {
  final List<String> liked;
  final List<String> disliked;
  final List<String> superliked;

  MatchedData(this.liked, this.disliked, this.superliked);
}

class SettingsService {
  static SettingsService? _instance;
  static SharedPreferences? _preferences;
  static Future<SettingsService> getInstance() async {
    if (_instance == null) {
      _instance = SettingsService();
    }
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  static const String _settingsPrefix = "FediMatch";

  static const String matchedDataKey = "${_settingsPrefix}MatchedData";
  static const String matchedDataKeyLiked = "${matchedDataKey}Liked";
  static const String matchedDataKeyDisliked = "${matchedDataKey}Disliked";
  static const String matchedDataKeySuperliked = "${matchedDataKey}Superliked";
  Future<MatchedData> matchedData() async {
    return MatchedData(
        _preferences!.getStringList(matchedDataKeyLiked) ?? [],
        _preferences!.getStringList(matchedDataKeyDisliked) ?? [],
        _preferences!.getStringList(matchedDataKeySuperliked) ?? []);
  }

  Future<void> updatematchedData(MatchedData matchedData) async {
    _preferences!.setStringList(matchedDataKeyLiked, matchedData.liked);
    _preferences!.setStringList(matchedDataKeyDisliked, matchedData.disliked);
    _preferences!
        .setStringList(matchedDataKeySuperliked, matchedData.superliked);
  }

  static const String themeModeKey = "${_settingsPrefix}Theme";
  static const ThemeMode themeModeDefault = ThemeMode.system;
  Future<ThemeMode> themeMode() async {
    if (_preferences!.containsKey(themeModeKey)) {
      String themeModeName = _preferences!.getString(themeModeKey)!;
      return ThemeMode.values.firstWhere((e) => e.name == themeModeName,
          orElse: () => themeModeDefault);
    }

    return themeModeDefault;
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    _preferences!.setString(themeModeKey, themeMode.name);
  }

  static const String userInstanceNameKey =
      "${_settingsPrefix}UserInstanceName";
  static const String userInstanceNameDefault = "mastodon.social";
  Future<String> userInstanceName() async {
    if (_preferences!.containsKey(userInstanceNameKey)) {
      return _preferences!.getString(userInstanceNameKey)!;
    }

    return userInstanceNameDefault;
  }

  Future<void> updateUserInstanceName(String userInstanceName) async {
    _preferences!.setString(userInstanceNameKey, userInstanceName);
  }

  static const String userNameKey = "${_settingsPrefix}UserName";
  static const String userNameDefault = "user";
  Future<String> userName() async {
    if (_preferences!.containsKey(userNameKey)) {
      return _preferences!.getString(userNameKey)!;
    }

    return userNameDefault;
  }

  Future<void> updateUserName(String userName) async {
    _preferences!.setString(userNameKey, userName);
  }
}
