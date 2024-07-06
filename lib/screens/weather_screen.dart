import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = 'Delhi';
  String weatherDescription = '';
  double temperature = 0.0;
  double humidity = 0.0;
  double windSpeed = 0.0;
  int windDirection = 0;
  int pressure = 0;
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    fetchweather().then((List<dynamic> data) {
      setState(() {
        temperature = data[3];
        humidity = data[4];
        pressure = data[5];
      });
    });
    fetchWeatherData();
    updateTime();
  }

  Future<List<dynamic>> fetchweather() async {
    final response = await http.get(Uri.parse(
        'https://script.google.com/macros/s/AKfycbwrlXyQCxeviINHe4nn9HjlbEBfAkBKeyVnLuL4ENakAQgn_PR-BKCJq-KRyvshXtx-/exec'));
    if (response.statusCode == 200) {
      final jsondata = json.decode(response.body);
      if (jsondata is List<dynamic> && jsondata.length >= 8) {
        return jsondata;
      } else {
        throw Exception('Invalid response format: $jsondata');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void updateTime() {
    setState(() {
      currentTime = DateTime.now().toString().substring(11, 19);
    });
    Future.delayed(Duration(seconds: 1), updateTime);
  }

  Future<void> fetchWeatherData() async {
    final apiKey = '37dbf41a4e288aaef9c1193969695604'; // Replace with your API key
    final cityName = 'delhi';
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';

    try {
      Response response = await Dio().get(apiUrl);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        setState(() {
          weatherDescription = jsonData['weather'][0]['description'];
          windSpeed = jsonData['wind']['speed'];
          windDirection = jsonData['wind']['deg'];
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Tracking'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.blueGrey,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location: $cityName',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Coordinates: 28.7041° N, 77.1025° E',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Time: $currentTime',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MeterBlock(
                        label: 'Temperature',
                        value: '${temperature.toStringAsFixed(1)}°C',
                        color: Colors.orange[300],
                      ),
                      MeterBlock(
                        label: 'Humidity',
                        value: '${humidity.toStringAsFixed(1)}%',
                        color: Colors.lightBlue[300],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MeterBlock(
                        label: 'Wind Speed',
                        value: '${windSpeed.toStringAsFixed(1)} m/s',
                        color: Colors.pink[300],
                      ),
                      MeterBlock(
                        label: 'Wind Direction',
                        value: '${getWindDirection(windDirection)}',
                        color: Colors.teal[300],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MeterBlock(
                        label: 'Pressure',
                        value: '${pressure.toStringAsFixed(1)} Pa',
                        color: Colors.green[300],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.blueGrey[700],
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'Weather: $weatherDescription',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
                  // Navigate to the WeatherScreen
                  Navigator.pushNamed(context, '/');
                },
              ),
              IconButton(
                icon: Icon(Icons.power, color: Colors.white),
                onPressed: () {
                  // Navigate to the SecondScreen
                  Navigator.pushNamed(context, '/second');
                },
              ),
              IconButton(
                icon: Icon(Icons.warning, color: Colors.white),
                onPressed: () {
                  // Navigate to the WeatherScreen
                  Navigator.pushNamed(context, '/third');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getWindDirection(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) {
      return 'N';
    } else if (degrees >= 22.5 && degrees < 67.5) {
      return 'NE';
    } else if (degrees >= 67.5 && degrees < 112.5) {
      return 'E';
    } else if (degrees >= 112.5 && degrees < 157.5) {
      return 'SE';
    } else if (degrees >= 157.5 && degrees < 202.5) {
      return 'S';
    } else if (degrees >= 202.5 && degrees < 247.5) {
      return 'SW';
    } else if (degrees >= 247.5 && degrees < 292.5) {
      return 'W';
    } else {
      return 'NW';
    }
  }
}

class MeterBlock extends StatelessWidget {
  final String? label;
  final String? value;
  final Color? color;

  const MeterBlock({
    Key? key,
    this.label,
    this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 120,
      decoration: BoxDecoration(
        color: color ?? Colors.grey,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? '',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            value ?? '',
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
