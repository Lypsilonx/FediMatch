import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  static String getHashFrom(List<Field> fields) {
    var hash = "";

    for (var i = 0; i < fields.length; i++) {
      hash += "&fields_attributes[$i][name]=${fields[i].name}";
      hash += "&fields_attributes[$i][value]=${fields[i].value}";
    }

    if (hash.length > 0) {
      hash = hash.substring(1);
    } else {
      hash = "fields_attributes[0][name]=&fields_attributes[0][value]=";
    }

    return hash;
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
  final String? language;
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

  final AccountSource? source;
  final Role? role;

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
          ? AccountSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      role: json.containsKey('role')
          ? Role.fromJson(json['role'] as Map<String, dynamic>)
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

  // ! This is a custom field that is not part of the Mastodon API
  bool hasFediMatchField() {
    return fields.any((e) => e.name == "FediMatch");
  }

  bool hasFediMatchKeyField() {
    return fields.any((e) => e.name == "FediMatchKey");
  }

  String getFediMatchPublickey() {
    if (!hasFediMatchKeyField()) {
      return "";
    }

    String fediMatchFieldValue =
        fields.where((e) => e.name == "FediMatchKey").first.value ?? "";

    return fediMatchFieldValue;
  }

  List<FediMatchTag> getFediMatchTags() {
    if (!hasFediMatchField()) {
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

class FediMatchTag {
  String tagType;
  String tagValue;

  FediMatchTag(this.tagType, this.tagValue);
}
// ! This is a custom field that is not part of the Mastodon API

class StatusMention {
  final String id;
  final String username;
  final String url;
  final String acct;

  StatusMention(
      {required this.id,
      required this.username,
      required this.url,
      required this.acct});

  factory StatusMention.fromJson(Map<String, dynamic> json) {
    return StatusMention(
      id: json['id'],
      username: json['username'],
      url: json['url'],
      acct: json['acct'],
    );
  }
}

class StatusTag {
  final String name;
  final String url;

  StatusTag({required this.name, required this.url});

  factory StatusTag.fromJson(Map<String, dynamic> json) {
    return StatusTag(name: json['name'], url: json['url']);
  }
}

class FilterKeyword {
  final String id;
  final String keyword;
  final bool wholeWord;

  FilterKeyword(
      {required this.id, required this.keyword, required this.wholeWord});

  factory FilterKeyword.fromJson(Map<String, dynamic> json) {
    return FilterKeyword(
        id: json['id'],
        keyword: json['keyword'],
        wholeWord: json['whole_word'] == "true");
  }
}

class FilterStatus {
  final String id;
  final String status_id;

  FilterStatus({required this.id, required this.status_id});

  factory FilterStatus.fromJson(Map<String, dynamic> json) {
    return FilterStatus(id: json['id'], status_id: json['status_id']);
  }
}

class Filter {
  final String id;
  final String title;
  final List<String> context;
  final String? expires_at;
  final String? filter_action;
  final List<FilterKeyword> keywords;
  final List<FilterStatus> statuses;

  Filter({
    required this.id,
    required this.title,
    required this.context,
    required this.expires_at,
    required this.filter_action,
    required this.keywords,
    required this.statuses,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      id: json['id'],
      title: json['title'],
      context:
          (json['context'] as List<dynamic>).map((e) => e as String).toList(),
      expires_at: json['expires_at'],
      filter_action: json['filter_action'],
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => FilterKeyword.fromJson(e as Map<String, dynamic>))
          .toList(),
      statuses: (json['statuses'] as List<dynamic>)
          .map((e) => FilterStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FilterResult {
  final Filter filter;
  final List<String>? keyword_matches;
  final List<String>? status_matches;

  FilterResult({
    required this.filter,
    required this.keyword_matches,
    required this.status_matches,
  });

  factory FilterResult.fromJson(Map<String, dynamic> json) {
    return FilterResult(
      filter: Filter.fromJson(json['filter'] as Map<String, dynamic>),
      keyword_matches: (json['keyword_matches'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status_matches: (json['status_matches'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

class StatusApplication {
  final String name;
  final String? website;

  StatusApplication({required this.name, required this.website});

  factory StatusApplication.fromJson(Map<String, dynamic> json) {
    return StatusApplication(name: json['name'], website: json['website']);
  }
}

class PollOption {
  final String title;
  final int? votesCount;

  PollOption({required this.title, required this.votesCount});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(title: json['title'], votesCount: json['votes_count']);
  }
}

class Poll {
  final String id;
  final String? expiresAt;
  final bool expired;
  final bool multiple;
  final int votesCount;
  final int? votersCount;
  final List<PollOption> options;
  final List<CustomEmoji> emojis;
  final bool? voted;
  final List<int>? ownVotes;

  Poll({
    required this.id,
    required this.expiresAt,
    required this.expired,
    required this.multiple,
    required this.votesCount,
    required this.votersCount,
    required this.options,
    required this.emojis,
    this.voted,
    this.ownVotes,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      expiresAt: json['expires_at'],
      expired: json['expired'] == "true",
      multiple: json['multiple'] == "true",
      votesCount: json['votes_count'],
      votersCount: json['voters_count'],
      options: (json['options'] as List<dynamic>)
          .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      emojis: (json['emojis'] as List<dynamic>)
          .map((e) => CustomEmoji.fromJson(e as Map<String, dynamic>))
          .toList(),
      voted: json.containsKey('voted') ? json['voted'] == "true" : null,
      ownVotes: json.containsKey('own_votes')
          ? (json['own_votes'] as List<dynamic>).map((e) => e as int).toList()
          : null,
    );
  }
}

class PreviewCard {
  final String url;
  final String title;
  final String description;
  final String type;
  final String authorName;
  final String authorUrl;
  final String providerName;
  final String providerUrl;
  final String html;
  final int width;
  final int height;
  final String? image;
  final String? embedUrl;
  final String? blurhash;

  PreviewCard({
    required this.url,
    required this.title,
    required this.description,
    required this.image,
    required this.type,
    required this.authorName,
    required this.authorUrl,
    required this.providerName,
    required this.providerUrl,
    required this.html,
    required this.width,
    required this.height,
    required this.embedUrl,
    required this.blurhash,
  });

  factory PreviewCard.fromJson(Map<String, dynamic> json) {
    return PreviewCard(
      url: json['url'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      type: json['type'],
      authorName: json['author_name'],
      authorUrl: json['author_url'],
      providerName: json['provider_name'],
      providerUrl: json['provider_url'],
      html: json['html'],
      width: json['width'],
      height: json['height'],
      embedUrl: json['embed_url'],
      blurhash: json['blurhash'],
    );
  }
}

class MediaAttachment {
  final String id;
  final String type;
  final String url;
  final String previewUrl;
  final String? remoteUrl;
  final Map<String, dynamic> meta;
  final String? description;
  final String blurhash;

  MediaAttachment({
    required this.id,
    required this.type,
    required this.url,
    required this.previewUrl,
    required this.remoteUrl,
    required this.meta,
    required this.description,
    required this.blurhash,
  });

  factory MediaAttachment.fromJson(Map<String, dynamic> json) {
    return MediaAttachment(
      id: json['id'],
      type: json['type'],
      url: json['url'],
      previewUrl: json['preview_url'],
      remoteUrl: json['remote_url'],
      meta: json['meta'] ?? {},
      description: json['description'],
      blurhash: json['blurhash'] ?? "",
    );
  }
}

class Status {
  final String id;
  final String uri;
  final String createdAt;
  final Account account;
  final String content;
  final String visibility;
  final bool sensitive;
  final String spoilerText;
  final List<MediaAttachment> mediaAttachments;
  final StatusApplication? application;
  final List<StatusMention> mentions;
  final List<StatusTag> tags;
  final List<CustomEmoji> emojis;
  final int reblogsCount;
  final int favouritesCount;
  final int repliesCount;
  final String? url;
  final String? inReplyToId;
  final String? inReplyToAccountId;
  final Status? reblog;
  final Poll? poll;
  final PreviewCard? card;
  final String? language;
  final String? text;
  final String? editedAt;
  final bool? favourited;
  final bool? reblogged;
  final bool? muted;
  final bool? bookmarked;
  final bool? pinned;
  final List<FilterResult>? filtered;

  Status({
    required this.id,
    required this.uri,
    required this.createdAt,
    required this.account,
    required this.content,
    required this.visibility,
    required this.sensitive,
    required this.spoilerText,
    required this.mediaAttachments,
    required this.application,
    required this.mentions,
    required this.tags,
    required this.emojis,
    required this.reblogsCount,
    required this.favouritesCount,
    required this.repliesCount,
    required this.url,
    required this.inReplyToId,
    required this.inReplyToAccountId,
    required this.reblog,
    required this.poll,
    required this.card,
    required this.language,
    required this.text,
    required this.editedAt,
    this.favourited,
    this.reblogged,
    this.muted,
    this.bookmarked,
    this.pinned,
    this.filtered,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'],
      uri: json['uri'],
      createdAt: json['created_at'],
      account: Account.fromJson(json['account']),
      content: json['content'],
      visibility: json['visibility'],
      sensitive: json['sensitive'] == "true",
      spoilerText: json['spoiler_text'],
      mediaAttachments: (json['media_attachments'] as List<dynamic>)
          .map((e) => MediaAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      application: json['application'] != null
          ? StatusApplication.fromJson(json['application'])
          : null,
      mentions: (json['mentions'] as List<dynamic>)
          .map((e) => StatusMention.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => StatusTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      emojis: (json['emojis'] as List<dynamic>)
          .map((e) => CustomEmoji.fromJson(e as Map<String, dynamic>))
          .toList(),
      reblogsCount: json['reblogs_count'],
      favouritesCount: json['favourites_count'],
      repliesCount: json['replies_count'],
      url: json['url'],
      inReplyToId: json['in_reply_to_id'],
      inReplyToAccountId: json['in_reply_to_account_id'],
      reblog: json['reblog'] != null
          ? Status.fromJson(json['reblog'] as Map<String, dynamic>)
          : null,
      poll: json['poll'] != null
          ? Poll.fromJson(json['poll'] as Map<String, dynamic>)
          : null,
      card: json['card'] != null
          ? PreviewCard.fromJson(json['card'] as Map<String, dynamic>)
          : null,
      language: json['language'],
      text: json['text'],
      editedAt: json['edited_at'],
      favourited:
          json.containsKey('favourited') ? json['favourited'] == "true" : null,
      reblogged:
          json.containsKey('reblogged') ? json['reblogged'] == "true" : null,
      muted: json.containsKey('muted') ? json['muted'] == "true" : null,
      bookmarked:
          json.containsKey('bookmarked') ? json['bookmarked'] == "true" : null,
      pinned: json.containsKey('pinned') ? json['pinned'] == "true" : null,
      filtered: json.containsKey('filtered')
          ? (json['filtered'] as List<dynamic>)
              .map((e) => FilterResult.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  HtmlWidget getContent({TextStyle? style, bool removeFirstLink = false}) {
    var contentWithEmojis = content;

    for (var emoji in emojis) {
      contentWithEmojis = contentWithEmojis.replaceAll(":${emoji.shortcode}:",
          "<img src='${emoji.staticUrl}' alt=':${emoji.shortcode}:' title=':${emoji.shortcode}:' width='20' style='vertical-align:middle;'>");
    }

    colorToHex(Color color) {
      return '#${color.value.toRadixString(16).substring(2)}';
    }

    if (removeFirstLink) {
      var firstLink = RegExp(r'^<p><span class="h-card" (.*)</span>')
          .firstMatch(contentWithEmojis);
      if (firstLink != null) {
        contentWithEmojis =
            contentWithEmojis.replaceFirst(firstLink.group(0)!, "<p>");
      }
    }

    return HtmlWidget(
      contentWithEmojis,
      textStyle: style,
      customStylesBuilder: (element) {
        if (element.localName == "a") {
          return {
            'color': colorToHex(style?.color ?? Colors.blue),
            'text-decoration': 'none'
          };
        }

        return null;
      },
    );
  }
}

class Conversation {
  late String id;
  late bool unread;
  late List<Account> accounts;
  late Status? lastStatus;

  Conversation({
    required this.id,
    required this.unread,
    required this.accounts,
    this.lastStatus,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      unread: json['unread'] == "true",
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastStatus: json.containsKey('last_status')
          ? Status.fromJson(json['last_status'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Report {
  late String id;
  late bool actionTaken;
  late String? actionTakenAt;
  late String category;
  late String comment;
  late bool forwarded;
  late String createdAt;
  late List<String>? statusIds;
  late List<String>? ruleIds;
  late Account targetAccount;

  Report({
    required this.id,
    required this.actionTaken,
    required this.actionTakenAt,
    required this.category,
    required this.comment,
    required this.forwarded,
    required this.createdAt,
    required this.statusIds,
    required this.ruleIds,
    required this.targetAccount,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      actionTaken: json['action_taken'] == "true",
      actionTakenAt: json['action_taken_at'],
      category: json['category'],
      comment: json['comment'],
      forwarded: json['forwarded'] == "true",
      createdAt: json['created_at'],
      statusIds: (json['status_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ruleIds:
          (json['rule_ids'] as List<dynamic>).map((e) => e as String).toList(),
      targetAccount: Account.fromJson(json['target_account']),
    );
  }
}

class RelationshipSeveranceEvent {
  late String id;
  late String type;
  late bool purged;
  late String targetName;
  late int? relationshipCount;
  late String createdAt;

  RelationshipSeveranceEvent({
    required this.id,
    required this.type,
    required this.purged,
    required this.targetName,
    this.relationshipCount,
    required this.createdAt,
  });

  factory RelationshipSeveranceEvent.fromJson(Map<String, dynamic> json) {
    return RelationshipSeveranceEvent(
      id: json['id'],
      type: json['type'],
      purged: json['purged'] == "true",
      targetName: json['target_name'],
      relationshipCount: json.containsKey('relationship_count')
          ? json['relationship_count']
          : null,
      createdAt: json['created_at'],
    );
  }
}

class Notification {
  late String id;
  late String type;
  late String createdAt;
  late Account account;
  late Status? status;
  late Report? report;
  late RelationshipSeveranceEvent? relationshipSeveranceEvent;

  Notification({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.account,
    this.status,
    this.report,
    this.relationshipSeveranceEvent,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      type: json['type'],
      createdAt: json['created_at'],
      account: Account.fromJson(json['account']),
      status: json.containsKey('status')
          ? Status.fromJson(json['status'] as Map<String, dynamic>)
          : null,
      report: json.containsKey('report')
          ? Report.fromJson(json['report'] as Map<String, dynamic>)
          : null,
      relationshipSeveranceEvent: json.containsKey('RelationshipSeveranceEvent')
          ? RelationshipSeveranceEvent.fromJson(
              json['RelationshipSeveranceEvent'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Context {
  late List<Status> ancestors;
  late List<Status> descendants;

  Context({required this.ancestors, required this.descendants});

  factory Context.fromJson(Map<String, dynamic> json) {
    return Context(
      ancestors: (json['ancestors'] as List<dynamic>)
          .map((e) => Status.fromJson(e as Map<String, dynamic>))
          .toList(),
      descendants: (json['descendants'] as List<dynamic>)
          .map((e) => Status.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Mastodon {
  static Mastodon? _instance;
  static Mastodon get instance => _instance!;
  Account self;

  Mastodon(Account self) : self = self {}

  static String clientId = "";
  static String clientSecret = "";

  static Future<(String clientId, String clientSecret)> registerClient(
      String instanceName) async {
    var result = await postToInstance(
      instanceName,
      "apps",
      body: <String, String>{
        'client_name': 'FediMatch',
        'redirect_uris': 'urn:ietf:wg:oauth:2.0:oob',
        'scopes': 'read write push',
      },
    );

    if (result.statusCode != 200) {
      throw Exception("Failed to register client (${result.body})");
    }

    var json = jsonDecode(result.body);

    clientId = json['client_id'];
    clientSecret = json['client_secret'];

    return (clientId, clientSecret);
  }

  static Future<String> OpenExternalLogin(String instanceName) async {
    if (instanceName.isEmpty) {
      return "Instance name is empty";
    }

    //check if https://<instanceName> is a valid URL (https://mastodon.social)
    if (!RegExp(r'^[a-zA-Z0-9.]+\.[a-zA-Z]+$').hasMatch(instanceName)) {
      return "Invalid instance name format";
    }

    try {
      var client = await registerClient(instanceName);
      clientId = client.$1;
      clientSecret = client.$2;
    } catch (e) {
      return "Failed to register client ($e)";
    }

    try {
      final Uri url = Uri.parse(
          'https://$instanceName/oauth/authorize?client_id=$clientId&scope=read+write+push&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code');
      launchUrl(url);
    } catch (e) {
      return "Failed to open external login ($e)";
    }

    return "OK";
  }

  static Future<String> Login(SettingsController controller, String authCode,
      String instanceName) async {
    var result = await http.post(
      Uri.parse('https://$instanceName/oauth/token'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': 'urn:ietf:wg:oauth:2.0:oob',
        'grant_type': 'authorization_code',
        'code': authCode,
        'scope': 'read write push',
      },
    );

    if (result.statusCode != 200) {
      return "Failed to get authorization code. (${result.body})";
    }

    String accessToken = jsonDecode(result.body)['access_token'];

    controller.updateUserInstanceName(instanceName);
    controller.updateAccessToken(accessToken);

    return await Update(instanceName, accessToken);
  }

  static Future<String> Update(String instanceName, String accessToken) async {
    var result = await getFromInstance(
        instanceName, "accounts/verify_credentials",
        accessToken: accessToken);

    if (result.statusCode != 200) {
      return "Failed to get user information. (${result.body})";
    }

    Account account =
        Account.fromJson(jsonDecode(result.body) as Map<String, dynamic>);

    _instance = Mastodon(account);
    return "OK";
  }

  static Future<void> Logout(SettingsController controller) async {
    await Matcher.deleteKeyValuePair();
    Matcher.uploaded = [];
    controller.updateUserInstanceName("");
    controller.updateAccessToken("");

    _instance = null;
    return;
  }

  static (String instance, String username) instanceUsernameFromUrl(
      String url) {
    String username = url.split("/").last;
    username = username.replaceFirst("@", "");
    String instance = url.replaceFirst("https://", "");
    instance = instance.split("/").first;

    return (instance, username);
  }

  static Future<Account> getAccount(
      String userInstanceName, String userName) async {
    var response = await getFromInstance(
        userInstanceName, "accounts/lookup?acct=$userName");

    if (response.statusCode == 200) {
      return Account.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception(
        "Failed to load user @$userName@$userInstanceName (${response.body})");
  }

  static Future<List<Status>> getAccountStatuses(
    String userInstanceName,
    String userId, {
    int limit = 20,
    bool excludeReblogs = false,
    bool excludeReplies = false,
    String? accessToken,
  }) async {
    var response = await getFromInstance(
      userInstanceName,
      "/accounts/$userId/statuses" +
          "?limit=$limit" +
          (excludeReblogs ? "?exclude_reblogs=true" : "") +
          (excludeReplies ? "?exclude_replies=true" : ""),
      accessToken: accessToken,
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((e) => Status.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Failed to load home timeline (${response.body})");
  }

  static Future<List<Conversation>> getConversations(
    String userInstanceName,
    String accessToken, {
    int limit = 20,
  }) async {
    var response = await getFromInstance(
      userInstanceName,
      "/conversations" + "?limit=$limit",
      accessToken: accessToken,
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Failed to load home timeline (${response.body})");
  }

  static Future<Context> getContext(
    String statusId,
    String userInstanceName,
    String accessToken,
  ) async {
    var response = await getFromInstance(
      userInstanceName,
      "/statuses/$statusId/context",
      accessToken: accessToken,
    );

    if (response.statusCode == 200) {
      return Context.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception("Failed to load home timeline (${response.body})");
  }

  static Future<List<Notification>> getNotifications(
    String userInstanceName,
    String accessToken, {
    int limit = 40,
    List<String>? types,
    String? accountId,
  }) async {
    var response = await getFromInstance(
      userInstanceName,
      "/notifications" +
          "?limit=$limit" +
          (accountId != null ? "&account_id=$accountId" : "") +
          (types != null ? "&types=${types.join(",")}" : ""),
      accessToken: accessToken,
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Failed to load home timeline (${response.body})");
  }

  static Future<String> sendStatus(
    String userInstanceName,
    String text,
    String accessToken, {
    String visibility = "public",
    String spoilerText = "",
    bool sensitive = false,
  }) async {
    var response = await postToInstance(
      userInstanceName,
      "statuses",
      accessToken: accessToken,
      body: <String, String>{
        'status': text,
        'visibility': visibility,
        'spoiler_text': spoilerText,
        'sensitive': sensitive ? "true" : "false",
      },
    );

    if (response.statusCode == 200) {
      return "OK";
    }

    return "Failed to send status (${response.body})";
  }

  static Future<List<Account>> getDirectory(
      {int limit = 10, int offset = 0}) async {
    var instanceUsername = instanceUsernameFromUrl(Mastodon.instance.self.url);
    String instance = instanceUsername.$1;
    var response = await getFromInstance(
        instance, "directory?limit=$limit&offset=$offset");

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Failed to load directory (${response.body})");
  }

  static Future<http.Response> getFromInstance(String instance, String path,
      {String? accessToken}) async {
    return http.get(
      Uri.parse('https://$instance/api/v1/$path'),
      headers: accessToken != null
          ? <String, String>{
              'Authorization': 'Bearer $accessToken',
            }
          : {},
    );
  }

  static Future<http.Response> postToInstance(String instance, String path,
      {String? accessToken, Map<String, String>? body}) async {
    return http.post(
      Uri.parse('https://$instance/api/v1/$path'),
      headers: accessToken != null
          ? <String, String>{
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/x-www-form-urlencoded',
            }
          : <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
            },
      body: body,
    );
  }

  // ! This is a custom field that is not part of the Mastodon API
  static Future<String> optInToFediMatch(
      String userInstanceName, String accessToken) async {
    if (Mastodon.instance.self.hasFediMatchField()) {
      return "Already opted in to FediMatch";
    }

    var fields = Mastodon.instance.self.fields;
    fields.add(
      Field(
        name: "FediMatch",
        value: "",
        verifiedAt: false,
      ),
    );

    var response = await http.patch(
      Uri.parse(
          "https://$userInstanceName/api/v1/accounts/update_credentials?" +
              Field.getHashFrom(fields)),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      return "OK";
    }

    return "Failed to opt in to FediMatch (${response.body})";
  }

  static Future<String> optInToFediMatchMatching(
      String userInstanceName, String accessToken, String password) async {
    if (Mastodon.instance.self.hasFediMatchKeyField()) {
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
      Uri.parse(
          "https://$userInstanceName/api/v1/accounts/update_credentials?" +
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

  static Future<String> optOutOfFediMatch(
      String userInstanceName, String accessToken) async {
    if (!Mastodon.instance.self.hasFediMatchField()) {
      return "Already opted out of FediMatch";
    }

    var fields = Mastodon.instance.self.fields;
    fields.removeWhere((element) => element.name == "FediMatch");

    var response = await http.patch(
      Uri.parse(
          'https://$userInstanceName/api/v1/accounts/update_credentials?' +
              Field.getHashFrom(fields)),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      if (Mastodon.instance.self.hasFediMatchKeyField()) {
        return await optOutOfFediMatchMatching(userInstanceName, accessToken);
      } else {
        return "OK";
      }
    }

    return "Failed to opt out of FediMatch (${response.body})";
  }

  static Future<String> optOutOfFediMatchMatching(
      String userInstanceName, String accessToken) async {
    if (!Mastodon.instance.self.hasFediMatchKeyField()) {
      return "Already opted out of FediMatch Matching";
    }

    var fields = Mastodon.instance.self.fields;
    fields.removeWhere((element) => element.name == "FediMatchKey");
    await Matcher.deleteKeyValuePair();
    Matcher.uploaded = [];

    var response = await http.patch(
      Uri.parse(
          'https://$userInstanceName/api/v1/accounts/update_credentials?' +
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
}
