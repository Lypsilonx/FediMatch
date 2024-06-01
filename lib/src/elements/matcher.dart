import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/settings/matched_data.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';

class Matcher {
  static List<String> liked = [];
  static List<String> disliked = [];
  static List<String> superliked = [];
  static List<String> matches = [];
  static List<String> any() => liked + disliked + superliked + matches;

  static List<String> uploaded = [];
  static List<Account> newMatches = [];

  static int numToUpload() {
    final List<String> toUpload = liked + superliked;

    toUpload.removeWhere((url) => uploaded.contains(url));

    return toUpload.length;
  }

  static String advertisedLink = "https://testflight.apple.com/join/Xf4FTWiG";

  static Future<String> uploadLikes() async {
    final Map<String, bool> toUpload = {};
    for (String url in liked) {
      toUpload[url] = false;
    }
    for (String url in superliked) {
      toUpload[url] = true;
    }

    toUpload.removeWhere((url, superlike) => uploaded.contains(url));

    List<String> data = [];

    for (var url in toUpload.keys) {
      var instanceUsername = Mastodon.instanceUsernameFromUrl(url);
      String instance = instanceUsername.$1;
      String username = instanceUsername.$2;
      Account account = await Mastodon.getAccount(instance, username);

      final remotePublicKey = account.getFediMatchPublickey();
      if (remotePublicKey == "") {
        continue;
      }

      String plainText = url + ":" + (toUpload[url]! ? "superlike" : "like");
      final encrypted = Crypotography.rsaEncrypt(remotePublicKey, plainText);

      data.add(encrypted.map((byte) => byte.toString()).join(","));
      uploaded.add(url);
    }

    if (data.isEmpty) {
      return "No new likes to upload";
    }

    var ownInstanceUsername =
        Mastodon.instanceUsernameFromUrl(Mastodon.instance.self.url);
    String ownInstance = ownInstanceUsername.$1;

    String message = advertisedLink + "?fedi_match_data=${data.join("|")}";

    Mastodon.sendStatus(
      ownInstance,
      message,
      SettingsController.instance.accessToken,
      visibility: "unlisted",
      spoilerText: "FediMatch",
      sensitive: true,
    );

    print("Uploaded ${data.length} likes");

    findMatches();

    saveToPrefs();
    return "OK";
  }

  static Future<String> findMatches() async {
    // go through unlisted toots of liked and superliked accounts and try to decrypt them
    // if successful, add to matches
    List<String> potentialMatches = liked + superliked;
    potentialMatches.removeWhere((url) => matches.contains(url));

    for (String url in potentialMatches) {
      var instanceUsername = Mastodon.instanceUsernameFromUrl(url);
      String instance = instanceUsername.$1;
      String username = instanceUsername.$2;

      print("Checking $instance $username");
      try {
        final account = await Mastodon.getAccount(instance, username);
        final statuses = await Mastodon.getAccountStatuses(instance, account.id,
            limit: 40, excludeReblogs: true, excludeReplies: true);

        for (Status status in statuses) {
          if (status.visibility != "unlisted") {
            continue;
          }

          String data =
              status.content.replaceAll("<p>", "").replaceAll("</p>", "");

          // extract data from link
          data = data.split("?fedi_match_data=")[1].split("\"")[0];

          for (String encrypted in data.split("|")) {
            print("Encrypted: $encrypted");
            // check if all characters are numbers or commas
            if (encrypted.characters
                .every((char) => char == "," || int.tryParse(char) != null)) {
              try {
                final decrypted = Crypotography.rsaDecrypt(
                    SettingsController.instance.privateMatchKey,
                    encrypted.split(",").map(int.parse).toList());
                print("Decrypted: $decrypted");
                if (decrypted.contains(Mastodon.instance.self.url)) {
                  addMatch(account);
                  break;
                }
              } catch (e) {
                print("Error: $e");
                continue;
              }
            }
          }
        }
      } catch (e) {
        print("Error: $e");
        continue;
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

  static void addToSuperliked(Account account) {
    if (any().contains(account.url)) {
      return;
    }

    superliked.add(account.url);
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
    superliked.remove(account.url);
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

  static void removeSuperlike(String url) {
    superliked.remove(url);
    saveToPrefs();
  }

  static void removeMatch(String url) {
    matches.remove(url);
    uploaded.remove(url);
    saveToPrefs();
  }

  static void clear() {
    SettingsController.instance
        .updateMatchedData(MatchedData([], [], [], [], []));
    loadFromPrefs();
  }

  static void saveToPrefs() {
    SettingsController.instance.updateMatchedData(
        MatchedData(liked, disliked, superliked, matches, uploaded));
  }

  static void loadFromPrefs() {
    MatchedData matchedData = SettingsController.instance.matchedData;
    liked = matchedData.liked;
    disliked = matchedData.disliked;
    superliked = matchedData.superliked;
    matches = matchedData.matches;
    uploaded = matchedData.uploaded;
  }

  static Future<String> generateKeyValuePair() async {
    final keyPair =
        Crypotography.generateRSAkeyPair(Crypotography.secureRandom());

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
