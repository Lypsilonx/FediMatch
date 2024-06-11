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
  int _currentRandomIndex = 0;
  int _currentFollowIndex = 0;
  AppinioSwiperController controller = AppinioSwiperController();
  String loadingMessage = "";

  List<(Account account, FediMatchAction action)> history = [];

  List<String> get relevantAccounts => Mastodon.selfFollowing + Matcher.liked;

  Future<void> _fetchAccounts() async {
    int goalSize = 5;
    int searchSize = 10;
    List<Account> accounts = [];
    try {
      do {
        List<Account> new_accounts = [];

        switch (SettingsController.instance.searchMode) {
          case FediMatchSearchMode.Random:
            new_accounts =
                await _fetchRandomAccounts(searchSize, _currentRandomIndex);
            _currentRandomIndex += new_accounts.length;
            break;
          case FediMatchSearchMode.Followers:
            if (_currentFollowIndex >= relevantAccounts.length) {
              new_accounts =
                  await _fetchRandomAccounts(searchSize, _currentRandomIndex);
            } else {
              while (relevantAccounts.length > _currentFollowIndex &&
                  Matcher.checked
                      .contains(relevantAccounts[_currentFollowIndex])) {
                _currentFollowIndex++;
              }
              try {
                new_accounts =
                    await _fetchFollowerAccounts(_currentFollowIndex);
              } catch (e) {
                print(e);
              }
              _currentFollowIndex++;
            }

            break;
        }
        ;

        var urls = [];
        new_accounts.retainWhere((element) {
          if (urls.contains(element.url)) {
            return false;
          }
          urls.add(element.url);
          return true;
        });

        // filter accounts
        accounts.addAll(
          new_accounts.where((element) {
            bool filtered = false;

            // filter out self
            if (element.url == Mastodon.instance.self.url) {
              filtered = true;
            }

            //filter stuff already in list or accounts
            if (_list.any((account) => account.url == element.url) ||
                accounts.any((account) => account.url == element.url)) {
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
          }).toList(),
        );
      } while (accounts.length < goalSize);
    } catch (e) {
      Util.showErrorScaffold(context, e.toString());
    }
    setState(() {
      _list.addAll(accounts);
    });
  }

  Future<List<Account>> _fetchRandomAccounts(int limit, int offset) async {
    setState(() {
      loadingMessage = "Searching for accounts... (${_currentRandomIndex})";
    });
    return await Mastodon.getDirectory(
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Account>> _fetchFollowerAccounts(int index) async {
    setState(() {
      loadingMessage =
          "Searching for relevant accounts... (${_currentFollowIndex})";
    });
    if (index >= relevantAccounts.length) {
      return [];
    }

    String url = relevantAccounts[index];
    Matcher.checked.add(url);
    var instanceUsername = FediMatchHelper.instanceUsernameFromUrl(url);
    var leader = await Mastodon.getAccount(
      instanceUsername.$1,
      instanceUsername.$2,
    );

    var statuses = await Mastodon.getAccountStatuses(
      leader,
      SettingsController.instance.accessToken,
    );

    List<Account> new_accounts = [];
    for (Status status in statuses) {
      if (status.reblog != null) {
        var account = status.reblog!.account;
        new_accounts.add(account);
      }

      for (StatusMention mention in status.mentions) {
        var instanceUsername =
            FediMatchHelper.instanceUsernameFromUrl(mention.url);
        var account = await Mastodon.getAccount(
          instanceUsername.$1,
          instanceUsername.$2,
        );

        new_accounts.add(account);
      }
    }

    return new_accounts;
  }

  @override
  void initState() {
    super.initState();
    Matcher.loadFromPrefs();
    _fetchAccounts();
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
              _currentRandomIndex++;
              if (next >= _list.length - 2) _fetchAccounts();

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
