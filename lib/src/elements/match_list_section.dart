import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:flutter/material.dart';

class MatchListSection extends StatefulWidget {
  final String title;
  final List<String> urls;
  final Color? color;
  final IconData? icon;
  final String? emptyMessage;
  final bool initiallyExpanded;
  final void Function(String url)? onDismissed;

  const MatchListSection(this.title, this.urls,
      {super.key,
      this.color,
      this.icon,
      this.emptyMessage,
      this.initiallyExpanded = false,
      this.onDismissed});

  @override
  State<MatchListSection> createState() => _MatchListSectionState();
}

class _MatchListSectionState extends State<MatchListSection> {
  Widget renderAsMatch(String url, int index) {
    var instanceUsername = Mastodon.instanceUsernameFromUrl(url);
    var instance = instanceUsername.$1;
    var username = instanceUsername.$2;
    Future<Account> account = Mastodon.getAccount(instance, username);
    return Dismissible(
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Icon(Icons.delete, color: Colors.white),
              )),
        ),
        key: Key(index.toString()),
        onDismissed: (direction) {
          if (widget.onDismissed != null) {
            setState(() {
              widget.onDismissed!(url);
            });
          }
        },
        child: FutureBuilder<Account>(
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
                child: AccountView(snapshot.data!, goto: "chat", edgeInset: 0),
              );
            } else {
              return ListTile(
                leading: CircularProgressIndicator(),
                title: Text("Loading... ($url)"),
              );
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: widget.initiallyExpanded,
      leading: widget.icon == null
          ? null
          : Icon(widget.icon, color: widget.color ?? Colors.black),
      title: Text(
        widget.title + " (${widget.urls.length})",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      children: widget.urls.isEmpty
          ? <Widget>[
              Text(
                widget.emptyMessage ?? "no matches yet",
                style: Theme.of(context).textTheme.labelLarge,
              )
            ]
          : [
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.urls.length,
                itemBuilder: (context, index) {
                  return renderAsMatch(widget.urls[index], index);
                },
              ),
            ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
