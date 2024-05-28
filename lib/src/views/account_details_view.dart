import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/match_buttons.dart';
import 'package:flutter/material.dart';

class AccountDetailsView extends StatefulWidget {
  final Account account;
  final AppinioSwiperController? controller;

  AccountDetailsView(this.account, {this.controller = null});

  static const routeName = '/account';

  @override
  State<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends State<AccountDetailsView> {
  ScrollController scrollController = ScrollController();
  List<Image> images = [];

  @override
  void initState() {
    super.initState();
    images = [
      Image(
          image: NetworkImage(widget.account.avatar),
          fit: BoxFit.cover,
          width: 430,
          height: 430),
      Image(
          image: NetworkImage(widget.account.avatar),
          fit: BoxFit.cover,
          width: 430,
          height: 430),
    ];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
      scrollController.addListener(() {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(controller: ScrollController(), children: [
        Container(
          width: 430,
          height: 430,
          child: images.length == 1
              ? images[0]
              : Stack(children: [
                  ListView(
                      physics: PageScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      controller: scrollController,
                      children: images),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Container(
                              height: 30,
                              width: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white.withOpacity(0.5),
                              ),
                              child: Text(
                                  scrollController.hasClients
                                      ? "${(scrollController.offset / 430).round() + 1}/${images.length}"
                                      : "",
                                  style: TextStyle(color: Colors.black))))),
                ]),
        ),
        Container(
          width: 430,
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.account.getDisplayName(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 24)),
                    Text("@" + widget.account.acct,
                        overflow: TextOverflow.ellipsis),
                    Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: widget.account.getNote()),
                  ])),
        ),
        widget.controller == null
            ? Container()
            : MatchButtons(
                controller: widget.controller!,
                postSwipe: () {
                  Navigator.pop(context);
                })
      ]),
    );
  }
}
