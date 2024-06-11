import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/dismissable_list.dart';
import 'package:flutter/material.dart';

class MatchListSection extends DismissableList {
  final String title;
  final List<String> urls;
  final String goto;
  final void Function(String url)? onMatchDismissed;

  MatchListSection(this.title, this.urls,
      {this.goto = "info",
      super.color,
      super.icon,
      super.emptyMessage,
      super.initiallyExpanded = false,
      this.onMatchDismissed})
      : super(title, urls.map((url) => renderAsMatch(url, goto)).toList(),
            onDismissed: (index) {
          onMatchDismissed!(urls[index]);
        }) {}

  static Widget renderAsMatch(String url, String goto) {
    var instanceUsername = FediMatchHelper.instanceUsernameFromUrl(url);
    var instance = instanceUsername.$1;
    var username = instanceUsername.$2;
    Future<Account> account = Mastodon.getAccount(instance, username);
    return FutureBuilder<Account>(
        future: account,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ListTile(
              leading: Icon(Icons.error),
              title: Text("Error loading account: $url (${snapshot.error})"),
            );
          }

          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 40),
              child: AccountView(snapshot.data!, goto: goto, edgeInset: 0),
            );
          } else {
            return ListTile(
              leading: CircularProgressIndicator(),
              title: Text("Loading... ($url)"),
            );
          }
        });
  }
}
