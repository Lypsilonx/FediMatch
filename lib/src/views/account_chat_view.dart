import 'dart:convert';
import 'dart:math';

import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/status_view.dart';
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
  bool messagesLoaded = false;

  @override
  void initState() {
    super.initState();

    var instanceUsername = Mastodon.instanceUsernameFromUrl(widget.account.url);
    var instance = instanceUsername.$1;
    var username = instanceUsername.$2;
    Mastodon.getAccount(instance, username).then((value) {
      setState(() async {
        actualAccount = value;

        await Mastodon.getAccountStatuses(instance, actualAccount.id,
                excludeReblogs: true, limit: 40)
            .then((statuses) {
          statuses
              //.where((status) => status.visibility == "private")
              .where((status) => status.mentions
                  .any((mention) => mention.url == Mastodon.instance.self.url))
              .forEach((status) {
            var message = types.CustomMessage(
              author: widget._recipient,
              createdAt:
                  DateTime.parse(status.createdAt).millisecondsSinceEpoch,
              id: status.id,
              metadata: {"type": "status", "status": status},
            );

            _addMessage(message);
          });
        });

        var selfInstanceUsername =
            Mastodon.instanceUsernameFromUrl(Mastodon.instance.self.url);
        String selfInstance = selfInstanceUsername.$1;

        await Mastodon.getAccountStatuses(
                selfInstance, Mastodon.instance.self.id,
                excludeReblogs: true, limit: 40)
            .then((statuses) {
          statuses
              //.where((status) => status.visibility == "private")
              .where((status) => status.mentions
                  .any((mention) => mention.url == actualAccount.url))
              .forEach((status) {
            var message = types.CustomMessage(
              author: widget._sender,
              createdAt:
                  DateTime.parse(status.createdAt).millisecondsSinceEpoch,
              id: status.id,
              metadata: {"type": "status", "status": status},
            );

            _addMessage(message);
          });
        });

        // sort messages by date
        _messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

        messagesLoaded = true;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AccountView(widget.account),
      ),
      body: Chat(
        emptyState: messagesLoaded
            ? Center(child: Text("No messages"))
            : Center(child: CircularProgressIndicator()),
        messages: messagesLoaded ? _messages : [],
        onSendPressed: _handleSendPressed,
        user: widget._sender,
        theme: FediMatchChatTheme.fromTheme(Theme.of(context)),
        customMessageBuilder: (message, {required int messageWidth}) {
          switch (message.metadata!["type"]) {
            case "status":
              return Padding(
                child:
                    StatusView(message.metadata!["status"], onlyContent: true),
                padding: EdgeInsets.all(10),
              );
            default:
              return Text("Unknown message type");
          }
        },
      ),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
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
