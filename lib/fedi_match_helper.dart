import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class FediMatchTag {
  String tagType;
  String tagValue;

  FediMatchTag(this.tagType, this.tagValue);

  static Map<String, Color> colors(ThemeData theme) {
    return {
      "none": theme.colorScheme.shadow,
      "interest": Colors.blue,
    };
  }

  static getColor(ThemeData theme, String tagType) {
    return HSLColor.fromColor(theme.colorScheme.secondary)
        .withHue(HSLColor.fromColor(colors(theme)[tagType]!).hue)
        .toColor()
        .withAlpha(100);
  }
}

class FediMatchFilter {
  String id;
  String mode;
  String search;
  String preference;
  int? value;

  FediMatchFilter(
    this.mode,
    this.search,
    this.preference, {
    this.value,
    String? id,
  }) : id = id ?? Uuid().v4();

  factory FediMatchFilter.fromJson(Map<String, dynamic> json) {
    return FediMatchFilter(
      json['mode'],
      json['search'],
      json['preference'],
      value: json['value'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode,
      'search': search,
      'preference': preference,
      'value': value,
    };
  }

  static Color color(String mode, ThemeData theme) {
    return switch (mode) {
      "must" => Colors.green.withAlpha(100),
      "preference" => Colors.blue.withAlpha(100),
      "cant" => theme.colorScheme.error.withAlpha(100),
      _ => theme.colorScheme.surfaceContainer,
    };
  }
}

extension AccountExtensions on Account {
  bool get hasFediMatchField {
    return fields.any((e) => e.name == "FediMatch");
  }

  bool get hasFediMatchKeyField {
    return fields.any((e) => e.name == "FediMatchKey");
  }

  String get fediMatchPublickey {
    if (!hasFediMatchKeyField) {
      return "";
    }

    String fediMatchFieldValue =
        fields.where((e) => e.name == "FediMatchKey").first.value ?? "";

    return fediMatchFieldValue;
  }

  List<FediMatchTag> get fediMatchTags {
    if (!hasFediMatchField) {
      return [];
    }

    String fediMatchFieldValue =
        fields.where((e) => e.name == "FediMatch").first.value ?? "";

    if (fediMatchFieldValue.isEmpty) {
      return [];
    }

    return fediMatchFieldValue.split(", ").map((e) {
      if (!e.contains(":")) {
        return FediMatchTag("none", e);
      }

      String tagType = e.split(":")[0];
      String tagValue = e.split(":")[1];
      return FediMatchTag(tagType, tagValue);
    }).toList();
  }
}

class FediMatchHelper {
  static Account get self => Mastodon.instance.self;

  static String get accessToken => SettingsController.instance.accessToken;

  static (String instance, String username) instanceUsernameFromUrl(
      String url) {
    String username = url.split("/").last;
    username = username.replaceFirst("@", "");
    String instance = url.replaceFirst("https://", "");
    instance = instance.split("/").first;

    return (instance, username);
  }

  static Future<String> optInToFediMatch() async {
    if (self.hasFediMatchField) {
      return "Already opted in to FediMatch";
    }

    var fields = self.fields;
    fields.add(
      Field(
        name: "FediMatch",
        value: "",
        verifiedAt: false,
      ),
    );

    var response = await http.patch(
      Uri.parse("https://${self.instance}/api/v1/accounts/update_credentials?" +
          Field.getHashFrom(fields)),
      headers: <String, String>{
        'Authorization': 'Bearer ${accessToken}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      return "OK";
    }

    return "Failed to opt in to FediMatch (${response.body})";
  }

  static Future<String> optInToFediMatchMatching(String password) async {
    if (Mastodon.instance.self.hasFediMatchKeyField) {
      return "Already opted in to FediMatch Matching";
    }

    String publicKey = await Matcher.generateKeyValuePair(password);
    var fields = Mastodon.instance.self.fields;
    fields.add(
      Field(
        name: "FediMatchKey",
        value: publicKey,
        verifiedAt: false,
      ),
    );

    var response = await http.patch(
      Uri.parse("https://${self.instance}/api/v1/accounts/update_credentials?" +
          Field.getHashFrom(fields)),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      return "OK";
    }

    return "Failed to opt in to FediMatch Matching (${response.body})";
  }

  static Future<String> optOutOfFediMatch() async {
    if (!Mastodon.instance.self.hasFediMatchField) {
      return "Already opted out of FediMatch";
    }

    var fields = Mastodon.instance.self.fields;
    fields.removeWhere((element) => element.name == "FediMatch");

    var response = await http.patch(
      Uri.parse('https://${self.instance}/api/v1/accounts/update_credentials?' +
          Field.getHashFrom(fields)),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      if (self.hasFediMatchKeyField) {
        return await optOutOfFediMatchMatching();
      } else {
        return "OK";
      }
    }

    return "Failed to opt out of FediMatch (${response.body})";
  }

  static Future<String> optOutOfFediMatchMatching() async {
    if (!self.hasFediMatchKeyField) {
      return "Already opted out of FediMatch Matching";
    }

    var fields = self.fields;
    fields.removeWhere((element) => element.name == "FediMatchKey");
    await Matcher.deleteKeyValuePair();
    Matcher.uploaded = [];
    Matcher.saveToPrefs();

    var response = await http.patch(
      Uri.parse('https://${self.instance}/api/v1/accounts/update_credentials?' +
          Field.getHashFrom(fields)),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      return "OK";
    }

    return "Failed to opt out of FediMatch Matching (${response.body})";
  }

  static Future<String> setFediMatchTags(List<FediMatchTag> tags) async {
    var fields = self.fields;
    fields.removeWhere((element) => element.name == "FediMatch");

    String fediMatchFieldValue =
        tags.map((e) => e.tagType + ":" + e.tagValue).toList().join(", ");

    fields.add(
      Field(
        name: "FediMatch",
        value: fediMatchFieldValue,
        verifiedAt: false,
      ),
    );

    var response = await http.patch(
      Uri.parse('https://${self.instance}/api/v1/accounts/update_credentials?' +
          Field.getHashFrom(fields)),
      headers: <String, String>{
        'Authorization': 'Bearer ${accessToken}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      return "OK";
    }

    return "Failed to set FediMatch tags (${response.body})";
  }
}
