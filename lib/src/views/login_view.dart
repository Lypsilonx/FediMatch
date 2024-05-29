import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key, required this.controller});

  static const routeName = '/login';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Instance Name',
                helperText: 'e.g. mastodon.social',
              ),
              initialValue: controller.userInstanceName,
              onChanged: controller.updateUserInstanceName,
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Username',
                helperText: 'e.g. MyAccount',
              ),
              initialValue: controller.userName,
              onChanged: controller.updateUserName,
            ),
            SizedBox(height: 20),
            TextButton(
              style: new ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.primary)),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text(
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                "Login",
              ),
            ),
          ]),
        ));
  }
}
