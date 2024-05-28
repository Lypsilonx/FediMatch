import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class CustomEmoji {
  final String? shortcode;
  final String? url;
  final String? staticUrl;
  final bool? visibleInPicker;

  CustomEmoji({
    required this.shortcode,
    required this.url,
    required this.staticUrl,
    required this.visibleInPicker,
  });

  factory CustomEmoji.fromJson(Map<String, dynamic> json) {
    return CustomEmoji(
      shortcode: json['shortcode'],
      url: json['url'],
      staticUrl: json['static_url'],
      visibleInPicker: json['visible_in_picker'] == "true",
    );
  }
}

class Field {
  final String? name;
  final String? value;
  final bool? verifiedAt;

  Field({
    required this.name,
    required this.value,
    required this.verifiedAt,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      name: json['name'],
      value: json['value'],
      verifiedAt: json['verified_at'] == "true",
    );
  }
}

class Role {
  final String id;
  final String name;
  final String color;
  final String permissions;
  final bool highlighted;

  Role({
    required this.id,
    required this.name,
    required this.color,
    required this.permissions,
    required this.highlighted,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      permissions: json['permissions'],
      highlighted: json['highlighted'] == "true",
    );
  }
}

class AccountSource {
  final String note;
  final List<Field> fields;
  final String privacy;
  final bool sensitive;
  final String language;
  final int followRequestsCount;

  AccountSource({
    required this.note,
    required this.fields,
    required this.privacy,
    required this.sensitive,
    required this.language,
    required this.followRequestsCount,
  });

  factory AccountSource.fromJson(Map<String, dynamic> json) {
    return AccountSource(
      note: json['note'],
      fields: (json['fields'] as List<dynamic>)
          .map((e) => Field.fromJson(e as Map<String, dynamic>))
          .toList(),
      privacy: json['privacy'],
      sensitive: json['sensitive'] == "true",
      language: json['language'],
      followRequestsCount: json['follow_requests_count'],
    );
  }
}

class Account {
  final String id;
  final String username;
  final String acct;
  final String url;
  final String displayName;
  final String note;
  final String avatar;
  final String avatarStatic;
  final String header;
  final String headerStatic;
  final bool locked;
  final List<Field> fields;
  final List<CustomEmoji> emojis;
  final bool bot;
  final bool group;
  final bool? discoverable;
  final bool? noindex;
  final bool? moved;
  final bool? suspended;
  final bool? limited;
  final String createdAt;
  final String? lastStatusAt;
  final int statusesCount;
  final int followersCount;
  final int followingCount;

  final List<AccountSource>? source;
  final List<Role>? role;

  final bool? muteExpiresAt;

  Account({
    required this.id,
    required this.username,
    required this.acct,
    required this.url,
    required this.displayName,
    required this.note,
    required this.avatar,
    required this.avatarStatic,
    required this.header,
    required this.headerStatic,
    required this.locked,
    required this.fields,
    required this.emojis,
    required this.bot,
    required this.group,
    required this.discoverable,
    this.noindex,
    this.moved,
    this.suspended,
    this.limited,
    required this.createdAt,
    required this.lastStatusAt,
    required this.statusesCount,
    required this.followersCount,
    required this.followingCount,
    this.source,
    this.role,
    this.muteExpiresAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      username: json['username'],
      acct: json['acct'],
      url: json['url'],
      displayName: json['display_name'],
      note: json['note'],
      avatar: json['avatar'],
      avatarStatic: json['avatar_static'],
      header: json['header'],
      headerStatic: json['header_static'],
      locked: json['locked'] == "true",
      fields: (json['fields'] as List<dynamic>)
          .map((e) => Field.fromJson(e as Map<String, dynamic>))
          .toList(),
      emojis: (json['emojis'] as List<dynamic>)
          .map((e) => CustomEmoji.fromJson(e as Map<String, dynamic>))
          .toList(),
      bot: json['bot'] == "true",
      group: json['group'] == "true",
      discoverable: json['discoverable'] == "true",
      noindex: json.containsKey('noindex') ? json['noindex'] == "true" : null,
      moved: json.containsKey('moved') ? json['moved'] == "true" : null,
      suspended:
          json.containsKey('suspended') ? json['suspended'] == "true" : null,
      limited: json.containsKey('limited') ? json['limited'] == "true" : null,
      createdAt: json['created_at'],
      lastStatusAt: json['last_status_at'],
      statusesCount: json['statuses_count'],
      followersCount: json['followers_count'],
      followingCount: json['following_count'],
      source: json.containsKey('source')
          ? (json['source'] as List<dynamic>)
              .map((e) => AccountSource.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      role: json.containsKey('role')
          ? (json['role'] as List<dynamic>)
              .map((e) => Role.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      muteExpiresAt: json.containsKey('mute_expires_at')
          ? json['mute_expires_at'] == "true"
          : null,
    );
  }

  HtmlWidget getNote() {
    var noteWithEmojis = note;

    for (var emoji in emojis) {
      noteWithEmojis = noteWithEmojis.replaceAll(":${emoji.shortcode}:",
          "<img src='${emoji.staticUrl}' alt=':${emoji.shortcode}:' title=':${emoji.shortcode}:' width='20' style='vertical-align:middle;'>");
    }

    return HtmlWidget(noteWithEmojis);
  }

  String getDisplayName() {
    var displayNameWithoutEmojis = displayName;

    for (var emoji in emojis) {
      displayNameWithoutEmojis =
          displayNameWithoutEmojis.replaceAll(":${emoji.shortcode}:", "");
    }

    return displayNameWithoutEmojis;
  }
}

class Mastodon {
  static Future<Account> getAccount(
      String userInstanceName, String userName) async {
    var response = await getFromInstance(
        userInstanceName, "api/v1/accounts/lookup?acct=$userName");

    if (response.statusCode == 200) {
      return Account.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception(
        "Failed to load user @$userName@$userInstanceName (${response.body})");
  }

  static Future<List<Account>> getDirectory(
      {int limit = 10, int offset = 0}) async {
    var response = await getFromInstance(
        "mastodon.social", "api/v1/directory?limit=$limit&offset=$offset");

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Failed to load directory (${response.body})");
  }

  static Future<http.Response> getFromInstance(
      String instance, String path) async {
    return http.get(Uri.parse('https://$instance/$path'));
  }
}
