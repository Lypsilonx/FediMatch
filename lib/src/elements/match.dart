import 'package:fedi_match/mastodon.dart';
import 'package:flutter/material.dart';

class Match extends StatefulWidget {
  final Account account;

  Match(this.account);

  @override
  State<Match> createState() => _MatchState();
}

class _MatchState extends State<Match> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(widget.account.avatar),
      ),
      title: Text(widget.account.displayName),
      subtitle: Text(widget.account.acct),
    );
  }
}
