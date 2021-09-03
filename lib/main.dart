// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:insaver/Screen/Home/home.dart';
import 'package:insaver/Screen/More/Policy/showDisclaimer.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:insaver/Utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:insaver/Utils/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then(
    (value) {
      runApp(
        ChangeNotifierProvider<ThemeNotifier>(
          create: (BuildContext context) {
            String theme = value.getString(Constants.APP_THEME) ?? '';
            if (theme == "" || theme == Constants.SYSTEM_DEFAULT) {
              value.setString(Constants.APP_THEME, Constants.SYSTEM_DEFAULT);
              return ThemeNotifier(ThemeMode.system);
            }
            return ThemeNotifier(
              theme == Constants.DARK ? ThemeMode.dark : ThemeMode.light,
            );
          },
          child: (value.getBool('disclaimer') ?? true)
              ? ShowDisclaimer()
              : MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.getThemeMode(),
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      home: Home(),
    );
  }
}
