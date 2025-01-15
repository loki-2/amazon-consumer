import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize settings
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // Always start with home view
  const initialRoute = '/home';

  runApp(MyApp(
    settingsController: settingsController,
    initialRoute: initialRoute,
  ));
}