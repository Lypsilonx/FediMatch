import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:fedi_match/src/elements/swipe_card.dart';
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

  Future<void> _fetchData(int pageKey) async {
    List<Account> accounts = [];
    try {
      do {
        //accounts.add(await mastodon.getAccount("kolektiva.social", "Lypsilonx"));
        List<Account> new_accounts =
            await Mastodon.getDirectory(limit: 50, offset: pageKey * 5);

        // filter accounts
        accounts.addAll(new_accounts.where((element) {
          bool filtered = false;

          return !filtered;
        }).toList());

        print("Seacedhing for accounts... $pageKey (${accounts.length})");

        pageKey++;
        _currentPage = pageKey;
      } while (accounts.length < 5);
    } catch (e) {
      print(e);
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
    return Scaffold(
      bottomNavigationBar: NavBar("Home"),
      appBar: AppBar(
        title: const Text('FediMatch'),
        actions: [
          controller.cardIndex != 0
              ? IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () {
                    controller.unswipe();
                  },
                )
              : Container(),
        ],
      ),
      body: AppinioSwiper(
        controller: controller,
        allowUnlimitedUnSwipe: true,
        cardCount: _list.length == 0 ? 1 : _list.length,
        swipeOptions: SwipeOptions.only(left: true, right: true, up: true),
        onSwipeEnd: (int current, int next, SwiperActivity activity) {
          _currentPage++;
          if (next >= _list.length - 2) _fetchData(_currentPage);

          switch (activity.runtimeType) {
            case Swipe:
              switch (activity.direction) {
                case AxisDirection.left:
                  Matcher.addToDisliked(_list[current]);
                  break;
                case AxisDirection.right:
                  Matcher.addToLiked(_list[current]);
                  break;
                case AxisDirection.up:
                  Matcher.addToSuperliked(_list[current]);
                  break;
                default:
              }
              break;
            case Unswipe:
              Matcher.unswipe(_list[next]);
              break;
            default:
              break;
          }

          setState(() {});
        },
        cardBuilder: (BuildContext context, int index) {
          if (_list.length == 0) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(
            padding: EdgeInsets.all(20),
            child: SwipeCard(controller, _list[index]),
          );
        },
      ),
    );
  }
}
