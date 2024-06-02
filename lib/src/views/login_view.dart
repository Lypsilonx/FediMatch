import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/fedi_match_logo.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const routeName = '/login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String instanceName = "";
  String authCode = "";
  int loginStep = 0;

  final textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (SettingsController.instance.userInstanceName != "" &&
        SettingsController.instance.accessToken != "") {
      Mastodon.Update(SettingsController.instance.userInstanceName,
              SettingsController.instance.accessToken)
          .whenComplete(() {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      });
    }

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
                            Mastodon.Login(SettingsController.instance,
                                authCode, instanceName),
                            context, onOK: () {
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
            _ => [],
          },
        ),
      ),
    );
  }
}
