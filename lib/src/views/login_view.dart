import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/fedi_match_logo.dart';
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.controller});

  static const routeName = 'login';

  static int loginStep = 0;

  final SettingsController controller;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String instanceName = "";
  String authCode = "";

  final textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.controller.userInstanceName != "" &&
        widget.controller.accessToken != "") {
      Mastodon.Resume(
              widget.controller.userInstanceName, widget.controller.accessToken)
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
                    if (result == "OK") {
                      setState(() {
                        textFieldController.clear();
                        LoginView.loginStep = 1;
                      });
                    } else {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Login Failed'),
                            content: Text(
                                result.replaceAll(RegExp(r'\n<link.*?>'), '')),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
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
                TextButton(
                  style: new ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary)),
                  onPressed: () async {
                    String result = await Mastodon.Login(
                        widget.controller, authCode, instanceName);
                    if (result == "OK") {
                      Navigator.pushReplacementNamed(context, "/");
                    } else {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Login Failed'),
                            content: Text(
                                result.replaceAll(RegExp(r'\n<link.*?>'), '')),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    "Login",
                  ),
                ),
              ],
            _ => [],
          },
        ),
      ),
    );
  }
}