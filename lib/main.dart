import 'package:flutter/material.dart';
import 'screens/weather_screen.dart';
import 'screens/second_screen.dart';
import 'screens/third_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      initialRoute: '/',
      routes: {
        '/': (context) => WeatherScreen(),
        '/second': (context) => SecondScreen(),
        '/third' : (context) => AnomalyDetectionScreen(),
      },
    );
  }
}
