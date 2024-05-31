import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/status_view.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class AccountChatView extends StatefulWidget {
  final Account account;
  final types.User _recipient;
  final types.User _sender;

  AccountChatView(this.account)
      : _recipient = types.User(id: account.url),
        _sender = types.User(id: Mastodon.instance.self.url);

  static const routeName = '/chat';

  @override
  State<AccountChatView> createState() => _AccountChatViewState();
}

class FediMatchChatTheme {
  static ChatTheme fromTheme(ThemeData theme) {
    return DefaultChatTheme(
      inputBackgroundColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      primaryColor: theme.colorScheme.primary,
      secondaryColor: theme.colorScheme.secondary,
      inputTextColor: theme.colorScheme.onPrimary,
      emptyChatPlaceholderTextStyle: new TextStyle(
        color: theme.colorScheme.onSurface,
      ),
      dateDividerTextStyle: new TextStyle(
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _AccountChatViewState extends State<AccountChatView> {
  ScrollController scrollController = ScrollController();
  late Account actualAccount = widget.account;
  final List<types.Message> _messages = [];
  List<types.Message> _messagesCache = [];
  bool messagesLoaded = false;

  @override
  void initState() {
    super.initState();

    var instanceUsername = Mastodon.instanceUsernameFromUrl(widget.account.url);
    var instance = instanceUsername.$1;
    var username = instanceUsername.$2;
    Mastodon.getAccount(instance, username).then((value) async {
      setState(() {
        actualAccount = value;

        updateChat();
      });
    });

    //call updateChat every 5 seconds
    Timer.periodic(Duration(seconds: 20), (timer) {
      updateChat();
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  Future<void> updateChat() async {
    setState(() {
      _messagesCache.clear();
      _messagesCache.addAll(_messages);
      messagesLoaded = false;
      _messages.clear();
    });

    var instanceUsername = Mastodon.instanceUsernameFromUrl(actualAccount.url);
    var instance = instanceUsername.$1;
    await Mastodon.getAccountStatuses(instance, actualAccount.id,
            excludeReblogs: true,
            limit: 40,
            accessToken: SettingsController.instance.accessToken)
        .then((statuses) {
      statuses
          .where((status) => status.visibility == "direct")
          .where((status) => status.mentions
              .any((mention) => mention.url == Mastodon.instance.self.url))
          .forEach((status) {
        var message = types.CustomMessage(
          author: widget._recipient,
          createdAt: DateTime.parse(status.createdAt).millisecondsSinceEpoch,
          id: status.id,
          metadata: {"type": "status", "status": status},
        );

        _messages.add(message);
      });
    });

    if (actualAccount.url != Mastodon.instance.self.url) {
      var selfInstanceUsername =
          Mastodon.instanceUsernameFromUrl(Mastodon.instance.self.url);
      String selfInstance = selfInstanceUsername.$1;

      var conversations = await Mastodon.getConversations(
        selfInstance,
        SettingsController.instance.accessToken,
        limit: 40,
      );

      conversations = conversations
          .where((conversation) =>
              conversation.accounts
                  .any((account) => account.url == actualAccount.url) &&
              conversation.lastStatus != null)
          .toList();

      for (var conversation in conversations) {
        var context = await Mastodon.getContext(conversation.lastStatus!.id,
            selfInstance, SettingsController.instance.accessToken);
        List<Status> statuses = [];
        statuses.add(conversation.lastStatus!);
        statuses.addAll(context.ancestors);
        statuses.forEach((status) {
          var message = types.CustomMessage(
            author: types.User(id: status.account.url),
            createdAt: DateTime.parse(status.createdAt).millisecondsSinceEpoch,
            id: status.id,
            metadata: {"type": "status", "status": status},
          );

          _messages.add(message);
        });
      }
      ;
    }

    // sort messages by date
    _messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    setState(() {
      messagesLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AccountView(widget.account),
        actions: [
          Container(
            width: 55,
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: updateChat,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Chat(
            emptyState: messagesLoaded
                ? Center(child: Text("No messages"))
                : Center(child: CircularProgressIndicator()),
            messages: messagesLoaded ? _messages : _messagesCache,
            onSendPressed: _handleSendPressed,
            user: widget._sender,
            theme: FediMatchChatTheme.fromTheme(Theme.of(context)),
            customMessageBuilder: (message, {required int messageWidth}) {
              switch (message.metadata!["type"]) {
                case "status":
                  return Padding(
                    child: StatusView(message.metadata!["status"],
                        onlyContent: true),
                    padding: EdgeInsets.all(10),
                  );
                default:
                  return Text("Unknown message type");
              }
            },
          ),
          Container(
            height: 2,
            width: 430,
            child: messagesLoaded
                ? null
                : Center(child: LinearProgressIndicator()),
          ),
        ],
      ),
    );
  }

  void _addMessage(types.Message message) async {
    switch (message.type) {
      case types.MessageType.text:
        var instanceUsername =
            Mastodon.instanceUsernameFromUrl(Mastodon.instance.self.url);
        var instance = instanceUsername.$1;
        var recipientInstanceUsername =
            Mastodon.instanceUsernameFromUrl(actualAccount.url);
        var recipientInstance = recipientInstanceUsername.$1;
        var recipientUsername = recipientInstanceUsername.$2;

        var recipientMention = "@$recipientUsername@$recipientInstance ";

        await Mastodon.sendStatus(
            instance,
            recipientMention + (message as types.TextMessage).text,
            SettingsController.instance.accessToken,
            visibility: "direct");
        break;
      default:
        break;
    }
    updateChat();
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: widget._sender,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
