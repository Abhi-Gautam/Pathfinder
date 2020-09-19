import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/animated_button_popup.dart';
import 'package:flutter_2d_grid/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_2d_grid/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  bool launch = true;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: PopUpModel(),
      child: Selector<PopUpModel, Brightness>(
        selector: (context, model) => model.brightness,
        builder: (context, brightness, __) {
          var model = Provider.of<PopUpModel>(context, listen: false);
          _getTheme().then((bri) => model.brightness = bri);
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.deepPurple,
                brightness: brightness,
              ),
              home:
                  Scaffold(backgroundColor: backgroundColor, body: HomePage()));
        },
      ),
    );
  }
}

Future<Brightness> _getTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getBool('darkMode') ?? false)
      ? Brightness.dark
      : Brightness.dark;
}
