import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsService = await SettingsService.getInstance();
  final settingsController = SettingsController(settingsService);
  await settingsController.loadSettings();
  runApp(MyApp(settingsController: settingsController));
}
