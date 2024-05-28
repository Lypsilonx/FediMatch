import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/settings/settings_service.dart';

class Matcher {
  static List<String> liked = [];
  static List<String> disliked = [];
  static List<String> superliked = [];

  static void addToLiked(Account account) {
    liked.add(account.acct);
    saveToPrefs();
  }

  static void addToDisliked(Account account) {
    disliked.add(account.acct);
    saveToPrefs();
  }

  static void addToSuperliked(Account account) {
    superliked.add(account.acct);
    saveToPrefs();
  }

  static void unswipe(Account account) {
    liked.remove(account.acct);
    disliked.remove(account.acct);
    superliked.remove(account.acct);
    saveToPrefs();
  }

  static void clear() {
    liked.clear();
    disliked.clear();
    superliked.clear();
    saveToPrefs();
  }

  static void saveToPrefs() async {
    SettingsService settingsService = await SettingsService.getInstance();
    settingsService.updatematchedData(MatchedData(liked, disliked, superliked));
  }

  static void loadFromPrefs() async {
    SettingsService settingsService = await SettingsService.getInstance();
    MatchedData matchedData = await settingsService.matchedData();
    liked = matchedData.liked;
    disliked = matchedData.disliked;
    superliked = matchedData.superliked;
  }
}
