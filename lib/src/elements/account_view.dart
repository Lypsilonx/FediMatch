import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/views/account_details_view.dart';
import 'package:fedi_match/src/views/account_chat_view.dart';
import 'package:flutter/material.dart';

class AccountView extends StatefulWidget {
  final Account account;
  final bool showIcon;
  final String goto;
  final double edgeInset;

  AccountView(this.account,
      {this.showIcon = true, this.goto = "info", this.edgeInset = 20});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  @override
  Widget build(BuildContext context) {
    var instanceUsername = Mastodon.instanceUsernameFromUrl(widget.account.url);
    var instance = instanceUsername.$1;
    return ListTile(
        contentPadding: EdgeInsets.all(widget.edgeInset),
        leading: widget.showIcon
            ? CircleAvatar(
                backgroundImage: NetworkImage(widget.account.avatar),
              )
            : null,
        title: widget.showIcon
            ? Text(
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                widget.account.getDisplayName(),
                overflow: TextOverflow.ellipsis,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    widget.account.getDisplayName(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                ],
              ),
        subtitle: Text(
          style: TextStyle(fontSize: 14),
          "@" + widget.account.username + "@" + instance,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          switch (widget.goto) {
            case "info":
              Navigator.pushNamed(context, AccountDetailsView.routeName,
                  arguments: {"account": widget.account});
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
