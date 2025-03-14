import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:fedi_match/src/views/account_chat_view.dart';
import 'package:fedi_match/src/views/chats_list_view.dart';
import 'package:fedi_match/src/views/matches_list_view.dart';
import 'package:fedi_match/src/views/login_view.dart';
import 'package:fedi_match/src/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'views/account_details_view.dart';
import 'views/account_list_view.dart';

/// The Widget that configures your application.
class FediMatch extends StatelessWidget {
  const FediMatch({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsController.instance,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          initialRoute: LoginView.routeName,
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: SettingsController.instance.theme,
          darkTheme: SettingsController.instance.darkTheme,
          themeMode: SettingsController.instance.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  return switch (routeSettings.name) {
                    LoginView.routeName => LoginView(),
                    SettingsView.routeName => SettingsView(),
                    ChatsListView.routeName => ChatsListView(),
                    MatchesListView.routeName => MatchesListView(),
                    AccountDetailsView.routeName => AccountDetailsView(
                        (routeSettings.arguments as Map)["account"] as Account,
                        controller: ((routeSettings.arguments as Map)
                                .containsKey("controller")
                            ? (routeSettings.arguments as Map)["controller"]
                            : null) as AppinioSwiperController?),
                    AccountChatView.routeName => AccountChatView(
                        (routeSettings.arguments as Map)["account"] as Account),
                    AccountListView.routeName => AccountListView(),
                    _ => AccountListView(),
                  };
                });
          },
        );
      },
    );
  }
}
