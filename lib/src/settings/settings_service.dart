import 'dart:convert';

import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/src/settings/matched_data.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Theme Color
  static const String themeColorKey = "${_settingsPrefix}ThemeColor";
  static const FlexScheme themeColorDefault = FlexScheme.red;
  Future<FlexScheme> themeColor() async {
    if (_preferences!.containsKey(themeColorKey)) {
      return FlexScheme.values[_preferences!.getInt(themeColorKey)!];
    }

    return themeColorDefault;
  }

  Future<void> updateThemeColor(FlexScheme themeColor) async {
    _preferences!.setInt(themeColorKey, themeColor.index);
  }

  // Theme Mode
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

  // Chat Mention Safety
  static const String chatMentionSafetyKey =
      "${_settingsPrefix}ChatMentionSafety";
  static const bool chatMentionSafetyDefault = true;
  Future<bool> chatMentionSafety() async {
    if (_preferences!.containsKey(chatMentionSafetyKey)) {
      return _preferences!.getBool(chatMentionSafetyKey)!;
    }

    return chatMentionSafetyDefault;
  }

  Future<void> updateChatMentionSafety(bool chatMentionSafety) async {
    _preferences!.setBool(chatMentionSafetyKey, chatMentionSafety);
  }

  // Show Non-Opt-In Accounts
  static const String showNonOptInAccountsKey =
      "${_settingsPrefix}ShowNonOptInAccounts";
  static const bool showNonOptInAccountsDefault = true;
  Future<bool> showNonOptInAccounts() async {
    if (_preferences!.containsKey(showNonOptInAccountsKey)) {
      return _preferences!.getBool(showNonOptInAccountsKey)!;
    }

    return showNonOptInAccountsDefault;
  }

  Future<void> updateShowNonOptInAccounts(bool showNonOptInAccounts) async {
    _preferences!.setBool(showNonOptInAccountsKey, showNonOptInAccounts);
  }

  // Filters
  static const String filtersKey = "${_settingsPrefix}Filters";
  static const List<FediMatchFilter> filtersDefault = [];
  Future<List<FediMatchFilter>> filters() async {
    if (_preferences!.containsKey(filtersKey)) {
      return _preferences!
          .getStringList(filtersKey)!
          .map((e) => FediMatchFilter.fromJson(jsonDecode(e)))
          .toList();
    }

    return filtersDefault;
  }

  Future<void> updateFilters(List<FediMatchFilter> filters) async {
    _preferences!
        .setStringList(filtersKey, filters.map((e) => jsonEncode(e)).toList());
  }

  // User Instance Name
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

  // Access Token
  static const String accessTokenKey = "${_settingsPrefix}AccessToken";
  static const String accessTokenDefault = "";
  Future<String> accessToken() async {
    if (_preferences!.containsKey(accessTokenKey)) {
      return _preferences!.getString(accessTokenKey)!;
    }

    return accessTokenDefault;
  }

  Future<void> updateAccessToken(String accessToken) async {
    _preferences!.setString(accessTokenKey, accessToken);
  }

  // Matched Data
  static const String matchedDataKey = "${_settingsPrefix}MatchedData";
  static const String matchedDataKeyLiked = "${matchedDataKey}Liked";
  static const String matchedDataKeyDisliked = "${matchedDataKey}Disliked";
  static const String matchedDataKeySuperliked = "${matchedDataKey}Superliked";
  static const String matchedDataKeyMatches = "${matchedDataKey}Matches";
  static const String matchedDataKeyUploaded = "${matchedDataKey}Uploaded";
  Future<MatchedData> matchedData() async {
    return MatchedData(
        _preferences!.getStringList(matchedDataKeyLiked) ?? [],
        _preferences!.getStringList(matchedDataKeyDisliked) ?? [],
        _preferences!.getStringList(matchedDataKeySuperliked) ?? [],
        _preferences!.getStringList(matchedDataKeyMatches) ?? [],
        _preferences!.getStringList(matchedDataKeyUploaded) ?? []);
  }

  Future<void> updateMatchedData(MatchedData matchedData) async {
    _preferences!.setStringList(matchedDataKeyLiked, matchedData.liked);
    _preferences!.setStringList(matchedDataKeyDisliked, matchedData.disliked);
    _preferences!
        .setStringList(matchedDataKeySuperliked, matchedData.superliked);
    _preferences!.setStringList(matchedDataKeyMatches, matchedData.matches);
    _preferences!.setStringList(matchedDataKeyUploaded, matchedData.uploaded);
  }

  // Private Match Key
  static const String privateMatchKeyKey = "${_settingsPrefix}PrivateMatchKey";
  static const String privateMatchKeyDefault = "";
  Future<String> privateMatchKey() async {
    if (_preferences!.containsKey(privateMatchKeyKey)) {
      return _preferences!.getString(privateMatchKeyKey)!;
    }

    return privateMatchKeyDefault;
  }

  Future<void> updatePrivateMatchKey(String privateMatchKey) async {
    _preferences!.setString(privateMatchKeyKey, privateMatchKey);
  }

  // Public Match Key
  static const String publicMatchKeyKey = "${_settingsPrefix}PublicMatchKey";
  static const String publicMatchKeyDefault = "";

  Future<String> publicMatchKey() async {
    if (_preferences!.containsKey(publicMatchKeyKey)) {
      return _preferences!.getString(publicMatchKeyKey)!;
    }

    return publicMatchKeyDefault;
  }

  Future<void> updatePublicMatchKey(String publicMatchKey) async {
    _preferences!.setString(publicMatchKeyKey, publicMatchKey);
  }
}
