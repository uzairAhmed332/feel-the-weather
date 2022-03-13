import 'package:feel_the_weather_new/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        appBarTheme: AppBarTheme(
          color: kBackgroundColor,
          elevation: 0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoadingScreen(),
    );
  }
}
