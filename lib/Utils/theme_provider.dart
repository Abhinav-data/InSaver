import 'package:flutter/material.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFF1e1e20),
    primaryColor: Colors.black,
    canvasColor: Colors.white,
    accentColor: Color(0xFFe1e1e1),
    buttonColor: Color(0xFF505050),
    colorScheme: ColorScheme.dark(),
    iconTheme: IconThemeData(color: Colors.white),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFFe7e7e7),
    primaryColor: Colors.white,
    accentColor: Colors.black,
    canvasColor: Colors.blue,
    buttonColor: Colors.grey[200],
    colorScheme: ColorScheme.light(),
    iconTheme: IconThemeData(color: Colors.black),
  );
}

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);

  getThemeMode() => _themeMode;

  setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class Constants {
  static String HOME = "Home";
  static String SETTING = "Setting";
  static String APP_THEME = "Theme";
  static String DARK = "Dark";
  static String LIGHT = "Light";
  static String SYSTEM_DEFAULT = "System default";
  static List<String> themes = ["System default", "Dark", "Light"];
  static String selectedThemeHeader = "You have set the theme to ";
  static String background_anim = "assets/day_night.flr";
  static String night_animation = "Daynight_normal";
  static String day_animation = "Daynight_reverse";
}
