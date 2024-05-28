import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/views/matches_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'views/account_details_view.dart';
import 'views/account_list_view.dart';
import 'settings/settings_controller.dart';
import 'views/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
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
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  return switch (routeSettings.name) {
                    SettingsView.routeName =>
                      SettingsView(controller: settingsController),
                    MatchesListView.routeName => MatchesListView(),
                    AccountDetailsView.routeName => AccountDetailsView(
                        (routeSettings.arguments as Map)["account"] as Account,
                        (routeSettings.arguments as Map)["controller"]
                            as AppinioSwiperController),
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
