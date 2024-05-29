import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:flutter/material.dart';

class StatusView extends StatelessWidget {
  final Status status;
  final bool isBoosted;

  const StatusView(this.status, {this.isBoosted = false});

  @override
  Widget build(BuildContext context) {
    return status.reblog != null
        ? StatusView(status.reblog!, isBoosted: true)
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(5),
            ),
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 300,
                    child: AccountView(status.account, edgeInset: 0),
                  ),
                  isBoosted == true ? Icon(Icons.rocket) : Container(),
                ],
              ),
              Column(children: [
                status.getContent(),
                status.card != null ? StatusCard(status.card!) : Container(),
              ]),
            ]),
          );
  }
}

class StatusCard extends StatelessWidget {
  final PreviewCard card;

  const StatusCard(this.card);

  @override
  Widget build(BuildContext context) {
    print(card.authorName);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.only(top: 10),
      child: Column(children: [
        Padding(
          padding: EdgeInsets.only(left: 15, right: 10, top: 10),
          child: Text(
            card.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15, right: 10, top: 10),
          child: Text(card.description),
        ),
        card.image == null
            ? Container()
            : Padding(
                padding: EdgeInsets.only(left: 15, right: 10, top: 10),
                child: Image.network(card.image!),
              ),
        Padding(
          padding: EdgeInsets.only(left: 15, right: 10, top: 10),
          child: Text(card.url),
        )
      ]),
    );
  }
}
