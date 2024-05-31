import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:fedi_match/src/settings/settings_service.dart';

class Matcher {
  static List<String> liked = [];
  static List<String> disliked = [];
  static List<String> superliked = [];
  static List<String> any() => liked + disliked + superliked + matches;

  static List<String> get matches {
    return []; // TODO implement matching
  }

  static void addToLiked(Account account) {
    if (any().contains(account.url)) {
      return;
    }

    liked.add(account.url);
    saveToPrefs();
  }

  static void addToDisliked(Account account) {
    if (any().contains(account.url)) {
      return;
    }

    disliked.add(account.url);
    saveToPrefs();
  }

  static void addToSuperliked(Account account) {
    if (any().contains(account.url)) {
      return;
    }

    superliked.add(account.url);
    saveToPrefs();
  }

  static void unswipe(Account account) {
    liked.remove(account.url);
    disliked.remove(account.url);
    superliked.remove(account.url);
    saveToPrefs();
  }

  static void remove(String url) {
    liked.remove(url);
    disliked.remove(url);
    superliked.remove(url);
    saveToPrefs();
  }

  static void clear() {
    liked.clear();
    disliked.clear();
    superliked.clear();
    saveToPrefs();
  }

  static void saveToPrefs() {
    SettingsController.instance
        .updateMatchedData(MatchedData(liked, disliked, superliked));
  }

  static void loadFromPrefs() {
    MatchedData matchedData = SettingsController.instance.matchedData;
    liked = matchedData.liked;
    disliked = matchedData.disliked;
    superliked = matchedData.superliked;
  }
}
