import 'dart:math';

import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/src/elements/fedi_match_logo.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:fedi_match/src/elements/swipe_card.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';

import 'package:fedi_match/mastodon.dart';
import 'package:appinio_swiper/appinio_swiper.dart';

/// Displays a list of SampleItems.
class AccountListView extends StatefulWidget {
  const AccountListView({super.key});

  static const routeName = '/';

  @override
  State<AccountListView> createState() => _AccountListViewState();
}

class _AccountListViewState extends State<AccountListView> {
  final _list = <Account>[];
  int _currentPage = 0;
  AppinioSwiperController controller = AppinioSwiperController();
  String loadingMessage = "";

  List<(Account account, FediMatchAction action)> history = [];

  Future<void> _fetchData(int pageKey) async {
    List<Account> accounts = [];
    // accounts.insert(
    //     0, await Mastodon.getAccount("kolektiva.social", "lypsilonx"));
    try {
      do {
        int pageSize = 50;
        List<Account> new_accounts = await Mastodon.getDirectory(
            limit: pageSize, offset: pageKey * pageSize);

        setState(() {
          loadingMessage =
              "Seacedhing for accounts... (${accounts.length}/${pageKey * pageSize})";
        });

        // filter accounts
        accounts.addAll(new_accounts.where((element) {
          bool filtered = false;

          // filter out self
          if (element.url == Mastodon.instance.self.url) {
            filtered = true;
          }

          // filter out disliked, liked and superliked accounts
          if (Matcher.any().any((accountUrl) => accountUrl == element.url)) {
            filtered = true;
          }

          if (!SettingsController.instance.showNonOptInAccounts &&
              !element.hasFediMatchField) {
            filtered = true;
          }

          if (!element
              .rateWithFilters(SettingsController.instance.filters)
              .$1) {
            filtered = true;
          }

          return !filtered;
        }).toList());

        pageKey++;
        _currentPage = pageKey;
      } while (accounts.length < 5);
    } catch (e) {
      Util.showErrorScaffold(context, e.toString());
    }
    setState(() {
      _list.addAll(accounts);
    });
  }

  @override
  void initState() {
    super.initState();
    Matcher.loadFromPrefs();
    _fetchData(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    FediMatchAction dislikeAction = FediMatchAction.Dislike;
    FediMatchAction? primaryAction = SettingsController.instance.primaryAction;
    FediMatchAction? secondaryAction =
        SettingsController.instance.secondaryAction;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          bottomNavigationBar: NavBar(AccountListView.routeName),
          appBar: AppBar(
            leading: history.length != 0
                ? IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      controller.unswipe();
                    },
                  )
                : Container(),
            title: FediMatchLogo(),
            actions: [
              Container(width: 50),
            ],
          ),
          body: AppinioSwiper(
            controller: controller,
            allowUnlimitedUnSwipe: true,
            cardCount: _list.length == 0 ? 1 : _list.length,
            swipeOptions: SwipeOptions.only(
              left: true,
              right: primaryAction != null,
              up: secondaryAction != null,
            ),
            onSwipeEnd: (int current, int next, SwiperActivity activity) {
              _currentPage++;
              if (next >= _list.length - 2) _fetchData(_currentPage);

              switch (activity.runtimeType) {
                case Swipe:
                  switch (activity.direction) {
                    case AxisDirection.left:
                      dislikeAction.action(context, _list[current]);
                      setState(() {
                        history.add((_list[current], dislikeAction));
                      });
                      break;
                    case AxisDirection.right:
                      if (primaryAction == null) break;
                      primaryAction.action(context, _list[current]);
                      setState(() {
                        history.add((_list[current], primaryAction));
                      });
                      break;
                    case AxisDirection.up:
                      if (secondaryAction == null) break;
                      secondaryAction.action(context, _list[current]);
                      setState(() {
                        history.add((_list[current], secondaryAction));
                      });
                      break;
                    default:
                  }
                  break;
                case Unswipe:
                  var last = history.removeLast();
                  last.$2.undo(context, last.$1);
                  break;
                default:
                  break;
              }

              setState(() {});
            },
            cardBuilder: (BuildContext context, int index) {
              if (_list.length == 0) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      Text(loadingMessage),
                    ],
                  ),
                );
              }

              var cardWidth =
                  min(constraints.maxWidth, constraints.maxHeight * 0.48);
              return Padding(
                padding: EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                    left: (constraints.maxWidth - cardWidth) / 2 + 20,
                    right: (constraints.maxWidth - cardWidth) / 2 + 20),
                child: SwipeCard(controller, _list[index]),
              );
            },
          ),
        );
      },
    );
  }
}
