import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class StatusView extends StatelessWidget {
  final Status status;
  final bool isBoosted;
  final bool onlyContent;
  final AppinioSwiperController? controller;

  const StatusView(this.status,
      {this.isBoosted = false, this.onlyContent = false, this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return status.reblog != null
            ? StatusView(status.reblog!,
                isBoosted: true, onlyContent: onlyContent)
            : GestureDetector(
                onLongPress: () => Util.showReportDialog(
                  context,
                  status.account,
                  () {
                    if (controller != null) {
                      controller!.swipeLeft();
                    }
                    Navigator.pop(
                      context,
                    );
                  },
                  status: status,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: onlyContent
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.surfaceContainer,
                    boxShadow: onlyContent ? [] : Util.boxShadow(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: onlyContent
                      ? EdgeInsets.all(0)
                      : EdgeInsets.only(top: 10),
                  padding: onlyContent
                      ? EdgeInsets.all(0)
                      : EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    children: [
                      onlyContent
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: constraints.maxWidth -
                                      (isBoosted ? 75 : 50),
                                  child:
                                      AccountView(status.account, edgeInset: 0),
                                ),
                                isBoosted == true
                                    ? Icon(Icons.rocket)
                                    : Container(),
                              ],
                            ),
                      Column(
                        children: [
                          status.spoilerText != ""
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      status.spoilerText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                )
                              : Container(),
                          status.getContent(
                              style: onlyContent
                                  ? TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 16)
                                  : null,
                              removeFirstLink: onlyContent),
                          SizedBox(
                              height: status.mediaAttachments.length > 0
                                  ? 20
                                  : 0), // onlyContent ? 0 : 20
                          status.mediaAttachments.length > 0
                              ? status.mediaAttachments.map(
                                  (e) {
                                    switch (e.type) {
                                      case "image":
                                        return Image.network(
                                          e.url,
                                          loadingBuilder: (context, child,
                                                  loadingProgress) =>
                                              loadingProgress == null
                                                  ? child
                                                  : BlurHash(
                                                      hash: e.blurhash,
                                                      imageFit: BoxFit.cover,
                                                    ),
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
                                  },
                                ).toList()[0]
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
