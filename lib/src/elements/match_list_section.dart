import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/match.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:flutter/material.dart';

class MatchListSection extends StatefulWidget {
  final String title;
  final List<String> urls;
  final Color? color;
  final IconData? icon;
  final String? emptyMessage;

  const MatchListSection(this.title, this.urls,
      {super.key, this.color, this.icon, this.emptyMessage});

  @override
  State<MatchListSection> createState() => _MatchListSectionState();
}

class _MatchListSectionState extends State<MatchListSection> {
  Widget renderAsMatch(
      String url, int index, Function(DismissDirection) onDismissed) {
    String username = url.split("/").last;
    username = username.replaceFirst("@", "");
    String instance = url.replaceFirst("https://", "");
    instance = instance.split("/").first;
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
          onDismissed(direction);
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
              return Match(snapshot.data!);
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
      initiallyExpanded: true,
      leading: widget.icon == null
          ? null
          : Icon(widget.icon, color: widget.color ?? Colors.black),
      title: Text(widget.title + " (${widget.urls.length})"),
      children: widget.urls.isEmpty
          ? <Widget>[Text(widget.emptyMessage ?? "no matches yet")]
          : [
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.urls.length,
                itemBuilder: (context, index) {
                  return renderAsMatch(widget.urls[index], index, (direction) {
                    setState(() {
                      Matcher.remove(widget.urls[index]);
                    });
                  });
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
