import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:insaver/Utils/routes.dart';
import 'package:insaver/Utils/theme_provider.dart';
import 'package:insaver/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowDisclaimer extends StatefulWidget {
  const ShowDisclaimer({Key? key}) : super(key: key);

  @override
  _ShowDisclaimerState createState() => _ShowDisclaimerState();
}

class _ShowDisclaimerState extends State<ShowDisclaimer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      home: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                  return true;
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 5000,
                      height: 200,
                      child: Stack(
                        children: [
                          Container(
                            width: 5000,
                            height: 200,
                            child: Image.asset(
                              'assets/images/d.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                'Welcome to Instagram Downloader',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'By tapping Continue, you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms of use ',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(context, '/term');
                                    },
                                ),
                                TextSpan(
                                  text: 'and confirm you have read our ',
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  ),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(context, '/privacy');
                                    },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: ElevatedButton(
                              onPressed: () async {
                                SharedPreferences value =
                                    await SharedPreferences.getInstance();
                                value.setBool('disclaimer', false).then(
                                  (v) {
                                    runApp(
                                      ChangeNotifierProvider<ThemeNotifier>(
                                        create: (BuildContext context) {
                                          String theme = value.getString(
                                                  Constants.APP_THEME) ??
                                              '';
                                          if (theme == "" ||
                                              theme ==
                                                  Constants.SYSTEM_DEFAULT) {
                                            value.setString(Constants.APP_THEME,
                                                Constants.SYSTEM_DEFAULT);
                                            return ThemeNotifier(
                                                ThemeMode.system);
                                          }
                                          return ThemeNotifier(
                                            theme == Constants.DARK
                                                ? ThemeMode.dark
                                                : ThemeMode.light,
                                          );
                                        },
                                        child: MyApp(),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: color,
                                minimumSize: Size(5000, 45),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
