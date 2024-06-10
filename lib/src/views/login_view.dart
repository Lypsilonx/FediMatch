import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/fedi_match_logo.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const routeName = 'login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String instanceName = "";
  String authCode = "";
  String matchingPassword = "";
  int loginStep = 0;

  final textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (SettingsController.instance.userInstanceName != "" &&
        SettingsController.instance.accessToken != "") {
      Mastodon.Update(
        SettingsController.instance.userInstanceName,
        SettingsController.instance.accessToken,
      ).whenComplete(() {
        if (Mastodon.instance.self.hasFediMatchKeyField &&
            SettingsController.instance.privateMatchKey == "") {
          setState(() {
            textFieldController.clear();
            loginStep = 2;
          });
          return;
        }
        Navigator.pushReplacementNamed(context, "/");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FediMatchLogo(),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: switch (loginStep) {
            0 => [
                SizedBox(height: 40),
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: textFieldController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Instance Name',
                    helperText: 'e.g. mastodon.social',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      instanceName = value;
                    });
                  },
                ),
                SizedBox(height: 60),
                TextButton(
                  style: new ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary)),
                  onPressed: () async {
                    Util.executeWhenOK(
                        Mastodon.OpenExternalLogin(instanceName), context,
                        onOK: () {
                      setState(() {
                        textFieldController.clear();
                        loginStep = 1;
                      });
                    });
                  },
                  child: Text(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    "Login with ${instanceName == "" ? "your Instance" : instanceName}",
                  ),
                ),
              ],
            1 => [
                SizedBox(height: 40),
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: textFieldController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Paste Code Here',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      authCode = value;
                    });
                  },
                ),
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: new ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.error)),
                      onPressed: () {
                        setState(() {
                          loginStep = 0;
                        });
                      },
                      child: Text(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onError),
                        "Back",
                      ),
                    ),
                    TextButton(
                      style: new ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primary)),
                      onPressed: () async {
                        Util.executeWhenOK(
                            Mastodon.Login(authCode, instanceName,
                                receiveInstanceName: SettingsController
                                    .instance.updateUserInstanceName,
                                receiveAccessToken: SettingsController
                                    .instance.updateAccessToken),
                            context, onOK: () {
                          if (Mastodon.instance.self.hasFediMatchKeyField &&
                              SettingsController.instance.privateMatchKey ==
                                  "") {
                            setState(() {
                              textFieldController.clear();
                              loginStep = 2;
                            });
                            return;
                          }

                          Navigator.pushReplacementNamed(context, "/");
                        });
                      },
                      child: Text(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        "Login",
                      ),
                    ),
                  ],
                ),
              ],
            2 => [
                SizedBox(height: 40),
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: textFieldController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Enter Matching-Password',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      matchingPassword = value;
                    });
                  },
                ),
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: new ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.error)),
                      onPressed: () {
                        setState(() {
                          loginStep = 0;
                        });
                      },
                      child: Text(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onError),
                        "Back",
                      ),
                    ),
                    TextButton(
                      style: new ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.error)),
                      onPressed: () async {
                        Util.executeWhenOK(
                            FediMatchHelper.optOutOfFediMatchMatching(),
                            context, onOK: () {
                          Navigator.pushReplacementNamed(context, "/");
                        });
                      },
                      child: Text(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onError),
                        "Opt-out",
                      ),
                    ),
                    TextButton(
                      style: new ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primary)),
                      onPressed: () async {
                        await Matcher.generateKeyValuePair(matchingPassword);
                        if (SettingsController.instance.publicMatchKey !=
                            Mastodon.instance.self.fediMatchPublickey) {
                          setState(() {
                            textFieldController.clear();
                            Util.showErrorScaffold(
                                context, "Matching Password not correct");
                          });
                          return;
                        }

                        Navigator.pushReplacementNamed(context, "/");
                      },
                      child: Text(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                        "Login",
                      ),
                    ),
                  ],
                ),
              ],
            _ => [],
          },
        ),
      ),
    );
  }
}
