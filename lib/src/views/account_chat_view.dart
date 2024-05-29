import 'dart:convert';
import 'dart:math';

import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class AccountChatView extends StatefulWidget {
  final Account account;
  final types.User _recipient;
  final types.User _sender;

  AccountChatView(this.account)
      : _recipient = types.User(id: account.url),
        _sender = types.User(id: Mastodon.self!.url);

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
    );
  }
}

class _AccountChatViewState extends State<AccountChatView> {
  ScrollController scrollController = ScrollController();
  final List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AccountView(widget.account),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: widget._recipient,
        theme: FediMatchChatTheme.fromTheme(Theme.of(context)),
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
      author: widget._recipient,
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
