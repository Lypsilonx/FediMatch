import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/settings/matched_data.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';

class Matcher {
  static List<String> liked = [];
  static List<String> disliked = [];
  static List<String> matches = [];
  static List<String> any() => liked + disliked + matches;

  static List<String> uploaded = [];
  static List<Account> newMatches = [];

  static int numToUpload() {
    final List<String> toUpload = liked;

    toUpload.removeWhere((url) => uploaded.contains(url));

    return toUpload.length;
  }

  static String advertisedLink = "https://ko-fi.com/s/125ba584c4";

  static Future<String> uploadLikes() async {
    final List<String> toUpload = liked;
    toUpload.removeWhere((url) => uploaded.contains(url));

    List<String> data = [];

    for (var url in toUpload) {
      var instanceUsername = FediMatchHelper.instanceUsernameFromUrl(url);
      String instance = instanceUsername.$1;
      String username = instanceUsername.$2;
      Account account = await Mastodon.getAccount(instance, username);

      final remotePublicKey = account.fediMatchPublickey;
      if (remotePublicKey == "") {
        continue;
      }

      String plainText = url + ":" + "like";
      final encrypted = Crypotography.rsaEncrypt(remotePublicKey, plainText);

      data.add(encrypted.map((byte) => byte.toString()).join(","));
      uploaded.add(url);
    }

    if (data.isEmpty) {
      return "No new likes to upload";
    }

    String message = advertisedLink + "?fedi_match_data=${data.join("|")}";

    Mastodon.sendStatus(
      Mastodon.instance.self.instance,
      message,
      SettingsController.instance.accessToken,
      visibility: "unlisted",
      spoilerText: "FediMatch",
      sensitive: true,
    );

    findMatches();

    saveToPrefs();
    return "OK";
  }

  static Future<String> findMatches() async {
    // go through unlisted toots of liked and superliked accounts and try to decrypt them
    // if successful, add to matches
    List<String> potentialMatches = liked;
    potentialMatches.removeWhere((url) => matches.contains(url));

    for (String url in potentialMatches) {
      var instanceUsername = FediMatchHelper.instanceUsernameFromUrl(url);
      String instance = instanceUsername.$1;
      String username = instanceUsername.$2;

      try {
        final account = await Mastodon.getAccount(instance, username);
        final statuses = await Mastodon.getAccountStatuses(
          account,
          SettingsController.instance.accessToken,
          limit: 40,
          excludeReblogs: true,
          excludeReplies: true,
        );

        for (Status status in statuses) {
          if (status.visibility != "unlisted") {
            continue;
          }

          String data =
              status.content.replaceAll("<p>", "").replaceAll("</p>", "");

          // extract data from link
          data = data.split("?fedi_match_data=")[1].split("\"")[0];

          for (String encrypted in data.split("|")) {
            // check if all characters are numbers or commas
            if (encrypted.characters
                .every((char) => char == "," || int.tryParse(char) != null)) {
              try {
                final decrypted = Crypotography.rsaDecrypt(
                    SettingsController.instance.privateMatchKey,
                    encrypted.split(",").map(int.parse).toList());
                if (decrypted.contains(Mastodon.instance.self.url)) {
                  addMatch(account);
                  break;
                }
              } catch (e) {
                return "Error: $e";
              }
            }
          }
        }
      } catch (e) {
        return "Error: $e";
      }
    }

    saveToPrefs();
    return "OK";
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

  static void addMatch(Account account) {
    if (matches.contains(account.url)) {
      return;
    }

    matches.add(account.url);
    newMatches.add(account);
    unswipe(account);
    saveToPrefs();
  }

  static void unswipe(Account account) {
    liked.remove(account.url);
    disliked.remove(account.url);
    saveToPrefs();
  }

  static void removeLike(String url) {
    liked.remove(url);
    saveToPrefs();
  }

  static void removeDislike(String url) {
    disliked.remove(url);
    saveToPrefs();
  }

  static void removeMatch(String url) {
    matches.remove(url);
    uploaded.remove(url);
    saveToPrefs();
  }

  static void clear() {
    SettingsController.instance.updateMatchedData(MatchedData([], [], [], []));
    loadFromPrefs();
  }

  static void resetDislikes() {
    SettingsController.instance
        .updateMatchedData(MatchedData(liked, [], matches, uploaded));
    loadFromPrefs();
  }

  static void saveToPrefs() {
    SettingsController.instance
        .updateMatchedData(MatchedData(liked, disliked, matches, uploaded));
  }

  static void loadFromPrefs() {
    MatchedData matchedData = SettingsController.instance.matchedData;
    liked = matchedData.liked;
    disliked = matchedData.disliked;
    matches = matchedData.matches;
    uploaded = matchedData.uploaded;
  }

  static Future<String> generateKeyValuePair(String password) async {
    final keyPair = Crypotography.generateRSAkeyPair(
        Crypotography.secureRandom(password + Mastodon.instance.self.url));

    final publicKey = Crypotography.fromPublicKey(keyPair.publicKey);
    final privateKey = Crypotography.fromPrivateKey(keyPair.privateKey);

    await SettingsController.instance.updatePrivateMatchKey(privateKey);
    await SettingsController.instance.updatePublicMatchKey(publicKey);

    return publicKey;
  }

  static Future<String> deleteKeyValuePair() async {
    SettingsController.instance.updatePrivateMatchKey("");
    SettingsController.instance.updatePublicMatchKey("");

    return "OK";
  }
}
