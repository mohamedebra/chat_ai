import 'package:chat_ai/hive/boxes.dart';
import 'package:chat_ai/hive/settings.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool isDarkMode = false;
  bool shouldSpeak = false;

  // get the saved settings from box
  void getSaveSetting() {
    final settingBox = Boxes.getSetting();
    // check if setting is not open
    if (settingBox.isNotEmpty) {
      // get the setting
      final setting = settingBox.getAt(0);

      isDarkMode = setting!.isDarkTheme;
      shouldSpeak = setting.shouldSpeak;
    }
  }

  // toggle the dark mode
  void toggleDarkMode({required bool value, Settings? settings}) {
    if (settings != null) {
      settings.isDarkTheme = value;
      settings.save();
    } else {
      final settingBox = Boxes.getSetting();

      settingBox.put(0, Settings(isDarkTheme: value, shouldSpeak: shouldSpeak));
    }
    isDarkMode = value;
    notifyListeners();
  }

  void toggleSpeak({
    required bool value,
    Settings? settings,
  }) {
    if (settings != null) {
      settings.shouldSpeak = value;
      settings.save();
    } else {
      // get the settings box
      final settingsBox = Boxes.getSetting();
      // save the settings
      settingsBox.put(0, Settings(isDarkTheme: isDarkMode, shouldSpeak: value));
    }

    shouldSpeak = value;
    notifyListeners();
  }
}
