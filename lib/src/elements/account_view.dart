import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/did_not_opt_in_icon.dart';
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
                style: Theme.of(context).textTheme.titleMedium,
                widget.account.getDisplayName() == ""
                    ? widget.account.username
                    : widget.account.getDisplayName(),
                overflow: TextOverflow.ellipsis,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style: Theme.of(context).textTheme.titleLarge,
                    widget.account.getDisplayName(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                ],
              ),
        subtitle: Text(
          style: Theme.of(context).textTheme.bodyMedium,
          "@" + widget.account.username + "@" + instance,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            !widget.account.hasFediMatchField() ? DidNotOptInIcon() : null,
        onTap: () {
          switch (widget.goto) {
            case "info":
              Navigator.pushNamed(context, AccountDetailsView.routeName,
                  arguments: {"account": widget.account});
              break;
            case "chat":
              if (!widget.account.hasFediMatchField()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("This user did not opt-in to FediMatch"),
                    action: SnackBarAction(
                      label: "Open Chat Anyway",
                      onPressed: () {
                        Navigator.pushNamed(context, AccountChatView.routeName,
                            arguments: {"account": widget.account});
                      },
                    )));
                return;
              }
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
