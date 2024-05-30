import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

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
                SizedBox(height: 20),
                status.mediaAttachments.length > 0
                    ? status.mediaAttachments.map((e) {
                        switch (e.type) {
                          case "image":
                            return Image.network(
                              e.url,
                              loadingBuilder:
                                  (context, child, loadingProgress) =>
                                      loadingProgress == null
                                          ? child
                                          : BlurHash(
                                              hash: e.blurhash,
                                              imageFit: BoxFit.cover),
                            );
                          case "video":
                            return Container();
                          case "gifv":
                            return Container();
                          case "unknown":
                            return Container();
                          default:
                            return Container();
                        }
                      }).toList()[0]
                    : Container(),
              ]),
            ]),
          );
  }
}
