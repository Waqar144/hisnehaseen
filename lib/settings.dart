import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:core';
import 'utils.dart' as utils;

/// Singleton settings class
class Settings extends ChangeNotifier {
  static final Settings _instance = Settings._private();
  static Settings get instance => _instance;

  Timer? timer;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode m) {
    if (m != _themeMode) {
      _themeMode = m;
      notifyListeners();
      persist();
    }
  }

  Future<void> saveToDisk() async {
    Map<String, dynamic> map = {
      'themeMode': _themeMode.index,
    };
    String json = const JsonEncoder.withIndent("  ").convert(map);
    await utils.saveJsonToDisk(json, "settings");
  }

  Future<void> readSettings() async {
    try {
      final Map<String, dynamic> json = await utils.readJsonFile("settings");
      _themeMode =
          ThemeMode.values[json["themeMode"] ?? ThemeMode.system.index];
    } catch (e) {
      // nothing for now
    }
  }

  void persist({int seconds = 1}) {
    timer?.cancel();
    timer = Timer(Duration(seconds: seconds), saveToDisk);
  }

  Settings._private();
}
