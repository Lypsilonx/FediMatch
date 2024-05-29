import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/views/account_details_view.dart';
import 'package:fedi_match/src/views/account_chat_view.dart';
import 'package:flutter/material.dart';

class AccountView extends StatefulWidget {
  final Account account;
  final String goto;
  final double edgeInset;

  AccountView(this.account, {this.goto = "info", this.edgeInset = 20});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.all(widget.edgeInset),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.account.avatar),
        ),
        title: Text(widget.account.getDisplayName()),
        subtitle: Text(widget.account.acct),
        onTap: () {
          switch (widget.goto) {
            case "info":
              Navigator.pushNamed(context, AccountDetailsView.routeName,
                  arguments: {"account": widget.account, "controller": null});
              break;
            case "chat":
              Navigator.pushNamed(context, AccountChatView.routeName,
                  arguments: {"account": widget.account});
              break;
          }
        },
        onLongPress: () {
          switch (widget.goto) {
            case "chat":
              Navigator.pushNamed(context, AccountDetailsView.routeName,
                  arguments: {"account": widget.account});
              break;
          }
        });
  }
}
