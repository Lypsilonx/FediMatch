import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class FediMatchListItem {
  final name;
  final description;
  final icon;
  final color;
  final Function(ThemeData theme)? pureColor;

  const FediMatchListItem(this.name, this.description, this.icon,
      {this.color = Colors.grey, this.pureColor = null});

  getColor(ThemeData theme) {
    if (pureColor != null) {
      return pureColor!(theme);
    }

    return HSLColor.fromColor(theme.colorScheme.secondary)
        .withHue(HSLColor.fromColor(color).hue)
        .toColor()
        .withAlpha(128);
  }
}

class FediMatchTagType extends FediMatchListItem {
  const FediMatchTagType(
    super.name,
    super.description,
    super.icon, {
    super.color = Colors.grey,
    super.pureColor = null,
  });

  static List<FediMatchTagType> get all => [Interest, None];

  static FediMatchTagType fromString(String name) {
    for (var type in all) {
      if (type.name == name) {
        return type;
      }
    }

    return FediMatchTagType(name, "", Icons.tag);
  }

  static const FediMatchTagType Interest = FediMatchTagType(
    "Interest",
    "Interests you have",
    Icons.star,
    color: Colors.blue,
  );

  static NoneColor(ThemeData theme) {
    return Colors.grey.withAlpha(100);
  }

  static const FediMatchTagType None = FediMatchTagType(
    "None",
    "No specific tag",
    Icons.tag,
    pureColor: NoneColor,
  );
}

class FediMatchAction extends FediMatchListItem {
  final Function(BuildContext context, Account account) action;
  final Function(BuildContext context, Account account) undo;

  const FediMatchAction(
    super.name,
    super.description,
    super.icon,
    this.action,
    this.undo, {
    super.color = Colors.grey,
    super.pureColor = null,
  });

  static List<FediMatchAction> get all => [Like, Follow, LikeAndFollow];

  static FediMatchAction fromString(String name) {
    for (var action in all) {
      if (action.name == name) {
        return action;
      }
    }

    return FediMatchAction(
        name, "", Icons.tag, (context, account) {}, (context, account) {});
  }

  static LikeAction(BuildContext context, Account account) {
    Matcher.addToLiked(account);
  }

  static LikeUndo(BuildContext context, Account account) {
    Matcher.unswipe(account);
  }

  static LikeColor(ThemeData theme) {
    return Colors.green;
  }

  static const FediMatchAction Like = FediMatchAction(
    "Like",
    "Like this person",
    Icons.favorite,
    LikeAction,
    LikeUndo,
    pureColor: LikeColor,
  );

  static DislikeAction(BuildContext context, Account account) {
    Matcher.addToDisliked(account);
  }

  static DislikeUndo(BuildContext context, Account account) {
    Matcher.unswipe(account);
  }

  static DislikeColor(ThemeData theme) {
    return Colors.red;
  }

  static const FediMatchAction Dislike = FediMatchAction(
    "Dislike",
    "Dislike this person",
    Icons.close,
    DislikeAction,
    DislikeUndo,
    pureColor: DislikeColor,
  );

  static FollowAction(BuildContext context, Account account) {
    String followStatus = Mastodon.selfFollowing.contains(account.url)
        ? "Following"
        : Mastodon.selfRequested.contains(account.url)
            ? "Requested"
            : "Follow";
    if (followStatus == "Follow") {
      Util.executeWhenOK(
        Mastodon.follow(account, SettingsController.instance.accessToken),
        context,
      );
    }
  }

  static FollowUndo(BuildContext context, Account account) {
    String followStatus = Mastodon.selfFollowing.contains(account.url)
        ? "Following"
        : Mastodon.selfRequested.contains(account.url)
            ? "Requested"
            : "Follow";
    if (followStatus != "Follow") {
      Util.executeWhenOK(
        Mastodon.unfollow(account, SettingsController.instance.accessToken),
        context,
      );
    }
  }

  static FollowColor(ThemeData theme) {
    return Colors.blue;
  }

  static const FediMatchAction Follow = FediMatchAction(
    "Follow",
    "Follow this person",
    Icons.person_add,
    FollowAction,
    FollowUndo,
    pureColor: FollowColor,
  );

  static LikeAndFollowAction(BuildContext context, Account account) {
    LikeAction(context, account);
    FollowAction(context, account);
  }

  static LikeAndFollowUndo(BuildContext context, Account account) {
    LikeUndo(context, account);
    FollowUndo(context, account);
  }

  static LikeAndFollowColor(ThemeData theme) {
    return Colors.purple;
  }

  static const FediMatchAction LikeAndFollow = FediMatchAction(
    "Like & Follow",
    "Like and follow this person",
    Icons.star,
    LikeAndFollowAction,
    LikeAndFollowUndo,
    pureColor: LikeAndFollowColor,
  );
}

class FediMatchSearchMode extends FediMatchListItem {
  const FediMatchSearchMode(
    super.name,
    super.description,
    super.icon, {
    super.color = Colors.grey,
    super.pureColor = null,
  });

  static List<FediMatchSearchMode> get all => [Random, Followers];

  static FediMatchSearchMode fromString(String name) {
    for (var mode in all) {
      if (mode.name == name) {
        return mode;
      }
    }

    return FediMatchSearchMode(name, "", Icons.search);
  }

  static const FediMatchSearchMode Random = FediMatchSearchMode(
    "Random",
    "Random accounts",
    Icons.shuffle,
    color: Colors.orange,
  );

  static const FediMatchSearchMode Followers = FediMatchSearchMode(
    "Followers",
    "Followers of your followers",
    Icons.people,
    color: Colors.blue,
  );
}

class FediMatchTag {
  FediMatchTagType tagType;
  String tagValue;

  FediMatchTag(this.tagType, this.tagValue);

  @override
  String toString() {
    if (tagType == FediMatchTagType.None) {
      return tagValue;
    }

    return tagType.name + ":" + tagValue;
  }
}

class FediMatchFilterMode extends FediMatchListItem {
  const FediMatchFilterMode(
    super.name,
    super.description,
    super.icon, {
    super.color = Colors.grey,
    super.pureColor = null,
  });

  static List<FediMatchFilterMode> get all => [Must, Preference, Cant];

  static FediMatchFilterMode fromString(String name) {
    for (var mode in all) {
      if (mode.name == name) {
        return mode;
      }
    }

    return FediMatchFilterMode(name, "", Icons.filter);
  }

  static const FediMatchFilterMode Must = FediMatchFilterMode(
    "Must",
    "Must match",
    Icons.check,
    color: Colors.green,
  );

  static const FediMatchFilterMode Preference = FediMatchFilterMode(
    "Should",
    "Should match",
    Icons.arrow_upward,
    color: Colors.blue,
  );

  static const FediMatchFilterMode Cant = FediMatchFilterMode(
    "Can't",
    "Must not match",
    Icons.close,
    color: Colors.red,
  );
}

class FediMatchFilter {
  String id;
  FediMatchFilterMode mode;
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
      FediMatchFilterMode.fromString(json['mode']),
      json['search'],
      json['preference'],
      value: json['value'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.name,
      'search': search,
      'preference': preference,
      'value': value,
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

    return fediMatchFieldValue.split(",").map((e) {
      if (!e.contains(":")) {
        return FediMatchTag(FediMatchTagType.None, e);
      }

      String tagName = e.split(":")[0];
      String tagValue = e.split(":")[1];
      return FediMatchTag(FediMatchTagType.fromString(tagName), tagValue);
    }).toList();
  }

  (bool, double) rateWithFilters(List<FediMatchFilter> filters) {
    List<FediMatchTag> tags = fediMatchTags;

    double score = 0;
    double total = 0;

    for (var filter in filters) {
      bool fulfilled = false;
      switch (filter.search) {
        case "tags":
          fulfilled = tags.any(
              (e) => e.tagType.name + ":" + e.tagValue == filter.preference);
          break;
        case "note":
          fulfilled =
              note.toLowerCase().contains(filter.preference.toLowerCase());
          break;
      }

      if (filter.mode == FediMatchFilterMode.Must) {
        if (!fulfilled) {
          return (false, 0);
        }
      } else if (filter.mode == FediMatchFilterMode.Preference) {
        if (fulfilled) {
          score += filter.value ?? 1;
        }
        total += filter.value ?? 1;
      } else if (filter.mode == FediMatchFilterMode.Cant) {
        if (fulfilled) {
          return (false, 0);
        }
      }
    }

    if (total == 0) {
      return (true, 0);
    }

    return (true, score / total);
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

  static int getFediMatchTagLength(List<FediMatchTag> tags) {
    return tags.map((e) => e.toString()).toList().join(",").length;
  }

  static Future<String> setFediMatchTags(List<FediMatchTag> tags) async {
    var fields = self.fields;
    fields.removeWhere((element) => element.name == "FediMatch");

    String fediMatchFieldValue =
        tags.map((e) => e.toString()).toList().join(",");

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
