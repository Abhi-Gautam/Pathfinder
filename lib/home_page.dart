import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_2d_grid/intro_page.dart';
import 'package:flutter_2d_grid/visualizer_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool finished = true;
  Future<bool> initialLaunch = _getLaunchState();
  @override
  Widget build(BuildContext context) {
    return finished
        ? ChangeNotifierProvider(
            create: (_) => OperationCountModel(), child: Visualizer())
        : FutureBuilder(
            future: initialLaunch,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data) {
                  return IntroductionPage(onDone: () {
                    _setLaunchState();
                    setState(() {
                      finished = true;
                    });
                  });
                } else {
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      finished = true;
                    });
                  });
                  return Center(child: CircularProgressIndicator());
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          );
  }
}

_setLaunchState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('initialLaunch', false);
}

Future<bool> _getLaunchState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getBool('initialLaunch') ?? true);
}
