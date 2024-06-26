import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_model.dart';

class SettingsProvider with ChangeNotifier {
  Settings _settings = Settings(dark: true, fast: true, language: 'en');

  Settings get settings => _settings;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString('settings') ?? '';
      if (settingsString.isNotEmpty) {
        _settings = Settings.fromJson(jsonDecode(settingsString));
      } else {
        await prefs.setString('settings', jsonEncode(_settings.toJson()));
      }
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/settings.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        _settings = Settings.fromJson(jsonDecode(contents));
      } else {
        await file.writeAsString(jsonEncode(_settings.toJson()));
      }
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings', jsonEncode(_settings.toJson()));
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/settings.json');
      await file.writeAsString(jsonEncode(_settings.toJson()));
    }
  }

  void toggleDarkMode(bool value) {
    _settings.dark = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleFastspeech(bool value) {
    _settings.fast = value;
    _saveSettings();
    notifyListeners();
  }

  void setLang(String value) {
    _settings.language = value;
    _saveSettings();
    notifyListeners();
  }

  void resetAll() {
    _settings.dark = true;
    _settings.fast = true;
    _settings.language = 'en';
    _saveSettings();
    notifyListeners();
  }
}
