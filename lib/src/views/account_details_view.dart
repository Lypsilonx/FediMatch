import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/match_buttons.dart';
import 'package:fedi_match/src/elements/status_view.dart';
import 'package:flutter/material.dart';

class AccountDetailsView extends StatefulWidget {
  final Account account;
  final AppinioSwiperController? controller;

  AccountDetailsView(this.account, {this.controller = null});

  static const routeName = '/account';

  static Map<String, Color> tagColors(ThemeData theme) {
    return {
      "interest": theme.colorScheme.primary,
    };
  }

  @override
  State<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends State<AccountDetailsView> {
  ScrollController scrollController = ScrollController();
  List<Image> images = [];
  late Account actualAccount = widget.account;
  late List<Status> accountStatuses = [];

  @override
  void initState() {
    super.initState();
    images = [
      Image(
          image: NetworkImage(widget.account.avatar),
          fit: BoxFit.cover,
          width: 430,
          height: 430),
    ];
    var instanceUsername = Mastodon.instanceUsernameFromUrl(widget.account.url);
    var instance = instanceUsername.$1;
    var username = instanceUsername.$2;
    Mastodon.getAccount(instance, username).then((value) {
      setState(() {
        actualAccount = value;

        Mastodon.getAccountStatuses(instance, actualAccount.id).then((value) {
          setState(() {
            accountStatuses = value;
            List<Image> new_images = value
                .where((element) =>
                    element.mediaAttachments.length > 0 &&
                    element.mediaAttachments[0].type == "image")
                .map((e) => Image(
                    image: NetworkImage(e.mediaAttachments[0].url),
                    fit: BoxFit.contain,
                    width: 430,
                    height: 430))
                .toList();

            if (new_images.length > 0) {
              images = new_images;
            }
          });
        });
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
      scrollController.addListener(() {
        setState(() {});
      });
    });
  }

  List<Widget> renderFediMatchTags(Account account) {
    return account.getFediMatchTags().map((e) {
      return Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          margin: EdgeInsets.only(top: 5, right: 5),
          decoration: BoxDecoration(
            color: AccountDetailsView.tagColors(Theme.of(context))[e.tagType]!
                .withAlpha(100),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(e.tagValue));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var instanceUsername = Mastodon.instanceUsernameFromUrl(actualAccount.url);
    var instance = instanceUsername.$1;
    //var username = instanceUsername.$2;
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
                              constraints: BoxConstraints(maxWidth: 60),
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white.withOpacity(0.5),
                              ),
                              child: Text(
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
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
                AccountView(actualAccount, goto: "none", edgeInset: 0),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: actualAccount.getNote(),
                ),
                Flex(
                    direction: Axis.horizontal,
                    children: renderFediMatchTags(actualAccount)),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: accountStatuses.length > 0 ||
                              actualAccount.statusesCount == 0
                          ? accountStatuses.map((e) => StatusView(e)).toList()
                          : [CircularProgressIndicator()]),
                ),
              ],
            ),
          ),
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
