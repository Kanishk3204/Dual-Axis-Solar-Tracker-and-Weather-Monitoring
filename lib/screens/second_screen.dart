import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:math';
import 'package:pie_chart/pie_chart.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FirstScreen(),
        '/second': (context) => SecondScreen(),
      },
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the SecondScreen
            Navigator.pushNamed(context, '/second');
          },
          child: Text('Go to Second Screen'),
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  late double solarPower = 0;
  late double altitude = 0;
  late double cloudcover = 0;
  late double temperature_2m = 0;
  late double relative_humidity_2m = 0;
  late int surface_pressure = 0;
  late int pressure = 0;

  @override
  void initState() {
    super.initState();
    fetchSolarPowerAndAltitude().then((List<dynamic> data) {
      setState(() {
        solarPower = data[7];
        altitude = data[6];
        temperature_2m = data[3];
        relative_humidity_2m = data[4];
        pressure = data[5];
        surface_pressure = pressure;
      });
    });
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final apiUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current=temperature_2m,relative_humidity_2m,dew_point_2m,precipitation,surface_pressure,wind_speed_100m,wind_direction_100m,sunshine_duration,direct_radiation,diffuse_radiation&units=metric';

    try {
      Response response = await Dio().get(apiUrl);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        setState(() {
          // double dew_point_2m = jsonData['current']['dew_point_2m'];
          // double precipitation = jsonData['current']['precipitation'];
          // double wind_speed_100m = jsonData['current']['wind_speed_100m'];
          // double wind_direction_100m =
          // jsonData['current']['wind_direction_100m'];
          // double sunshine_duration = jsonData['current']['sunshine_duration'];
          // double direct_radiation = jsonData['current']['direct_radiation'];
          // double diffuse_radiation = jsonData['current']['diffuse_radiation'];
          double dew_point_2m = jsonData['current']['dew_point_2m'].toDouble();
          double precipitation = jsonData['current']['precipitation'].toDouble();
          double wind_speed_100m = jsonData['current']['wind_speed_100m'].toDouble();
          double wind_direction_100m = jsonData['current']['wind_direction_100m'].toDouble();
          double sunshine_duration = jsonData['current']['sunshine_duration'].toDouble();
          double direct_radiation = jsonData['current']['direct_radiation'].toDouble();
          double diffuse_radiation = jsonData['current']['diffuse_radiation'].toDouble();
          cloudcover = 2.6245916 * temperature_2m +
              0.4823458 * relative_humidity_2m -
              0.7531799 * dew_point_2m +
              19.641594 * precipitation +
              0.12740988 * surface_pressure +
              0.38813043 * wind_speed_100m -
              0.019238045 * wind_direction_100m -
              0.0025914013 * sunshine_duration -
              0.047477826 * direct_radiation +
              0.17429824 * diffuse_radiation -
              193.97754;
          cloudcover = cloudcover / 10;
          print(cloudcover);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<List<dynamic>> fetchSolarPowerAndAltitude() async {
    final response = await http.get(Uri.parse(
        'https://script.google.com/macros/s/AKfycbwrlXyQCxeviINHe4nn9HjlbEBfAkBKeyVnLuL4ENakAQgn_PR-BKCJq-KRyvshXtx-/exec'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is List<dynamic> && jsonData.length >= 8) {
        return jsonData;
      } else {
        throw Exception('Invalid response format: $jsonData');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solar Output Screen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Altitude',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      VerticalBarChart(value: altitude),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Solar Output',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomPaint(
                        painter: SemicircularMeterPainter(value: solarPower),
                        child: Container(
                          width: 200,
                          height: 100,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Range: 0 - 7.39 mW',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Current Output: ${solarPower.toStringAsFixed(1)} mW',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: PieChart(
                      dataMap: {
                        'Clear': 100 - cloudcover,
                        'Cloudy': cloudcover,
                      },
                      colorList: [Colors.grey[300]!, Colors.orange],
                      chartType: ChartType.ring,
                      chartRadius: 100,
                      ringStrokeWidth: 20,
                      initialAngleInDegree: 270,
                      legendOptions: LegendOptions(showLegendsInRow: false),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValues: false,
                      ),
                      centerText: 'Cloud Cover',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          color: Colors.blueGrey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.sunny, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
              IconButton(
                icon: Icon(Icons.power, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/second');
                },
              ),
              IconButton(
                icon: Icon(Icons.warning, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/third');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SemicircularMeterPainter extends CustomPainter {
  final double value;

  SemicircularMeterPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    Paint backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    Paint valuePaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    double centerX = width / 2;
    double centerY = height;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: height),
      pi,
      pi,
      true,
      backgroundPaint,
    );

    double sweepAngle = (value / 7.39) * pi;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: height),
      pi,
      sweepAngle,
      true,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class VerticalBarChart extends StatelessWidget {
  final double value;

  const VerticalBarChart({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(width: 4),
        Text(
          '${value.toString()} m',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}



