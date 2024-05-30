import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/fedi_match_logo.dart';
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const routeName = 'login';

  static int loginStep = 0;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String instanceName = "";
  String authCode = "";

  final textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (SettingsController.instance.userInstanceName != "" &&
        SettingsController.instance.accessToken != "") {
      Mastodon.Update(SettingsController.instance.userInstanceName,
              SettingsController.instance.accessToken)
          .whenComplete(() {
        Navigator.pushReplacementNamed(context, "/");
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
          children: switch (LoginView.loginStep) {
            0 => [
                SizedBox(height: 40),
                const Text('Login', style: TextStyle(fontSize: 24)),
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
                    String result =
                        await Mastodon.OpenExternalLogin(instanceName);
                    print(result);
                    if (result == "OK") {
                      setState(() {
                        textFieldController.clear();
                        LoginView.loginStep = 1;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          result,
                          style: new TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        showCloseIcon: true,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ));
                    }
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
                const Text('Login', style: TextStyle(fontSize: 24)),
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
                          LoginView.loginStep = 0;
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
                        String result = await Mastodon.Login(
                            SettingsController.instance,
                            authCode,
                            instanceName);
                        if (result == "OK") {
                          Navigator.pushReplacementNamed(context, "/");
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              result,
                              style: new TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                            showCloseIcon: true,
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ));
                        }
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
