import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/fedi_match_helper.dart';
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

  static List<Widget> renderFediMatchTags(
      BuildContext context, Account account) {
    return account.fediMatchTags.map((e) {
      return Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          margin: EdgeInsets.only(top: 5, right: 5),
          decoration: BoxDecoration(
            color: FediMatchTag.getColor(Theme.of(context), e.tagType),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(e.tagValue));
    }).toList();
  }

  @override
  State<AccountDetailsView> createState() => _AccountDetailsViewState();
}

class _AccountDetailsViewState extends State<AccountDetailsView> {
  ScrollController scrollController = ScrollController();
  List<String> imageUrls = [];
  late Account actualAccount = widget.account;
  late List<Status> accountStatuses = [];

  @override
  void initState() {
    super.initState();
    imageUrls = [
      widget.account.avatar,
    ];
    Mastodon.getAccount(widget.account.instance, widget.account.username)
        .then((value) {
      setState(() {
        actualAccount = value;

        Mastodon.getAccountStatuses(widget.account.instance, actualAccount.id)
            .then((value) {
          setState(() {
            accountStatuses = value;
            List<String> new_images = value
                .where((element) =>
                    element.mediaAttachments.length > 0 &&
                    element.mediaAttachments[0].type == "image")
                .map((e) => e.mediaAttachments[0].url)
                .toList();

            if (new_images.length > 0) {
              imageUrls = new_images;
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            controller: ScrollController(),
            children: [
              Container(
                width: constraints.maxWidth,
                height: constraints.maxWidth,
                child: imageUrls.length == 1
                    ? Image(
                        image: NetworkImage(
                          imageUrls[0],
                        ),
                        fit: BoxFit.cover,
                        width: constraints.maxWidth,
                        height: constraints.maxWidth,
                      )
                    : Stack(
                        children: [
                          ListView(
                            physics: PageScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            controller: scrollController,
                            children: imageUrls
                                .map(
                                  (e) => Image(
                                    image: NetworkImage(e),
                                    fit: BoxFit.cover,
                                    width: constraints.maxWidth,
                                    height: constraints.maxWidth,
                                  ),
                                )
                                .toList(),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: 60,
                                ),
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
                                      ? "${(scrollController.offset / constraints.maxWidth).round() + 1}/${imageUrls.length}"
                                      : "",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
                width: constraints.maxWidth,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountView(
                        actualAccount,
                        goto: "none",
                        edgeInset: 0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 20,
                        ),
                        child: actualAccount.getNote(),
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: AccountDetailsView.renderFediMatchTags(
                          context,
                          actualAccount,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: accountStatuses.length > 0 ||
                                  actualAccount.statusesCount == 0
                              ? accountStatuses
                                  .where((element) =>
                                      element.visibility == "public")
                                  .map((e) => StatusView(e))
                                  .toList()
                              : [
                                  CircularProgressIndicator(),
                                ],
                        ),
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
                        Navigator.pop(
                          context,
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}
