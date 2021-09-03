import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:insaver/Utils/constants.dart';
import 'package:insaver/Utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChange extends StatefulWidget {
  @override
  _ThemeChangeState createState() => _ThemeChangeState();
}

class _ThemeChangeState extends State<ThemeChange> {
  int _selectedPosition = 0;
  var isDarkTheme;
  List themes = Constants.themes;
  SharedPreferences? prefs;
  ThemeNotifier? themeNotifier;
  Widget ad = Container();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getSavedTheme();
    });
    ad = AppodealBanner();
  }

  _getSavedTheme() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPosition = themes.indexOf(
          prefs!.getString(Constants.APP_THEME) ?? Constants.SYSTEM_DEFAULT);
    });
  }

  @override
  Widget build(BuildContext context) {
    themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Theme",
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              ListTile(
                leading: Radio(
                  value: 0,
                  groupValue: _selectedPosition,
                  activeColor: Color(0xFFf85343),
                  onChanged: (int? val) {
                    setState(() {
                      _selectedPosition = val!;
                    });
                    _updateState(val!);
                  },
                ),
                title: Text('System default'),
                onTap: () {
                  setState(() {
                    _selectedPosition = 0;
                  });
                  _updateState(0);
                },
              ),
              ListTile(
                leading: Radio(
                  value: 1,
                  groupValue: _selectedPosition,
                  activeColor: Color(0xFFf85343),
                  onChanged: (int? val) {
                    setState(() {
                      _selectedPosition = val!;
                    });
                    _updateState(val!);
                  },
                ),
                title: Text('Dark Mode'),
                onTap: () {
                  setState(() {
                    _selectedPosition = 1;
                  });
                  _updateState(1);
                },
              ),
              ListTile(
                leading: Radio(
                  value: 2,
                  groupValue: _selectedPosition,
                  activeColor: Color(0xFFf85343),
                  onChanged: (int? val) {
                    setState(() {
                      _selectedPosition = val!;
                    });
                    _updateState(val!);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedPosition = 2;
                  });
                  _updateState(2);
                },
                title: Text('Light Mode'),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              child: ad,
            ),
          ),
        ],
      ),
    );
  }

  _updateState(int position) {
    setState(() {
      _selectedPosition = position;
    });
    onThemeChanged(themes[position]);
  }

  void onThemeChanged(String value) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == Constants.SYSTEM_DEFAULT) {
      themeNotifier!.setThemeMode(ThemeMode.system);
    } else if (value == Constants.DARK) {
      themeNotifier!.setThemeMode(ThemeMode.dark);
    } else {
      themeNotifier!.setThemeMode(ThemeMode.light);
    }
    prefs.setString(Constants.APP_THEME, value);
  }
}
