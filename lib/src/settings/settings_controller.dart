import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/src/settings/matched_data.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  static late SettingsController _instance;
  static SettingsController get instance => _instance;

  Future<void> loadSettings() async {
    _searchMode = await _settingsService.searchMode();
    _themeColor = await _settingsService.themeColor();
    updateThemeColor(_themeColor);
    _themeMode = await _settingsService.themeMode();
    _chatMentionSafety = await _settingsService.chatMentionSafety();
    _primaryAction = await _settingsService.primaryAction();
    _secondaryAction = await _settingsService.secondaryAction();

    _showNonOptInAccounts = await _settingsService.showNonOptInAccounts();
    _filters = await _settingsService.filters();
    _showRating = await _settingsService.showRating();

    _userInstanceName = await _settingsService.userInstanceName();
    _accessToken = await _settingsService.accessToken();
    _matchedData = await _settingsService.matchedData();
    _privateMatchKey = await _settingsService.privateMatchKey();
    _publicMatchKey = await _settingsService.publicMatchKey();

    _instance = this;

    notifyListeners();
  }

  late FediMatchSearchMode _searchMode;
  FediMatchSearchMode get searchMode => _searchMode;

  Future<void> updateSearchMode(FediMatchSearchMode? newSearchMode) async {
    if (newSearchMode == null) return;
    if (newSearchMode == _searchMode) return;

    _searchMode = newSearchMode;

    notifyListeners();
    await _settingsService.updateSearchMode(newSearchMode);
  }

  late ThemeData _darkTheme;
  ThemeData get darkTheme => _darkTheme;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late FlexScheme _themeColor;
  FlexScheme get themeColor => _themeColor;

  void updateThemeColor(FlexScheme? newThemeColor) async {
    if (newThemeColor == null) return;

    _themeColor = newThemeColor;
    _theme = FlexThemeData.light(scheme: newThemeColor, useMaterial3: true);
    _darkTheme = FlexThemeData.dark(scheme: newThemeColor, useMaterial3: true);

    notifyListeners();
    await _settingsService.updateThemeColor(themeColor);
  }

  late ThemeData _theme;
  ThemeData get theme => _theme;

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  late FediMatchAction? _primaryAction;
  FediMatchAction? get primaryAction => _primaryAction;

  Future<void> updatePrimaryAction(FediMatchAction? newPrimaryAction) async {
    if (newPrimaryAction == _primaryAction) return;

    _primaryAction = newPrimaryAction;

    notifyListeners();
    await _settingsService.updatePrimaryAction(newPrimaryAction);
  }

  late FediMatchAction? _secondaryAction;
  FediMatchAction? get secondaryAction => _secondaryAction;

  Future<void> updateSecondaryAction(
      FediMatchAction? newSecondaryAction) async {
    if (newSecondaryAction == _secondaryAction) return;

    _secondaryAction = newSecondaryAction;

    notifyListeners();
    await _settingsService.updateSecondaryAction(newSecondaryAction);
  }

  late bool _showNonOptInAccounts;
  bool get showNonOptInAccounts => _showNonOptInAccounts;

  Future<void> updateShowNonOptInAccounts(bool newShowNonOptInAccounts) async {
    if (newShowNonOptInAccounts == _showNonOptInAccounts) return;

    _showNonOptInAccounts = newShowNonOptInAccounts;

    notifyListeners();
    await _settingsService.updateShowNonOptInAccounts(newShowNonOptInAccounts);
  }

  late List<FediMatchFilter> _filters;
  List<FediMatchFilter> get filters => _filters;

  Future<String> updateFilters(List<FediMatchFilter> newFilters) async {
    if (newFilters == _filters) return "OK";

    _filters = newFilters;

    notifyListeners();
    await _settingsService.updateFilters(newFilters);
    return "OK";
  }

  late bool _showRating;
  bool get showRating => _showRating;

  Future<void> updateShowRating(bool newShowRating) async {
    if (newShowRating == _showRating) return;

    _showRating = newShowRating;

    notifyListeners();
    await _settingsService.updateShowRating(newShowRating);
  }

  late bool _chatMentionSafety;
  bool get chatMentionSafety => _chatMentionSafety;

  Future<void> updateChatMentionSafety(bool newChatMentionSafety) async {
    if (newChatMentionSafety == _chatMentionSafety) return;

    _chatMentionSafety = newChatMentionSafety;

    notifyListeners();
    await _settingsService.updateChatMentionSafety(newChatMentionSafety);
  }

  late String _userInstanceName;
  String get userInstanceName => _userInstanceName;

  Future<void> updateUserInstanceName(String? newuserInstanceName) async {
    if (newuserInstanceName == null) return;
    if (newuserInstanceName == _userInstanceName) return;

    _userInstanceName = newuserInstanceName;

    notifyListeners();
    await _settingsService.updateUserInstanceName(newuserInstanceName);
  }

  late String _accessToken;
  String get accessToken => _accessToken;

  Future<void> updateAccessToken(String? newAccessToken) async {
    if (newAccessToken == null) return;
    if (newAccessToken == _accessToken) return;

    _accessToken = newAccessToken;

    notifyListeners();
    await _settingsService.updateAccessToken(newAccessToken);
  }

  late MatchedData _matchedData;
  MatchedData get matchedData => _matchedData;

  Future<void> updateMatchedData(MatchedData? newMatchedData) async {
    if (newMatchedData == null) return;
    if (newMatchedData == _matchedData) return;

    _matchedData = newMatchedData;

    notifyListeners();
    await _settingsService.updateMatchedData(newMatchedData);
  }

  late String _privateMatchKey;
  String get privateMatchKey => _privateMatchKey;

  Future<void> updatePrivateMatchKey(String newPrivateMatchKey) async {
    if (newPrivateMatchKey == _privateMatchKey) return;

    _privateMatchKey = newPrivateMatchKey;

    notifyListeners();
    await _settingsService.updatePrivateMatchKey(newPrivateMatchKey);
  }

  late String _publicMatchKey;
  String get publicMatchKey => _publicMatchKey;

  Future<void> updatePublicMatchKey(String newPublicMatchKey) async {
    if (newPublicMatchKey == _publicMatchKey) return;

    _publicMatchKey = newPublicMatchKey;

    notifyListeners();
    await _settingsService.updatePublicMatchKey(newPublicMatchKey);
  }
}
