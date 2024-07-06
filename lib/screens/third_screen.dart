import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class AnomalyDetectionScreen extends StatefulWidget {
  @override
  _AnomalyDetectionScreenState createState() => _AnomalyDetectionScreenState();
}

class _AnomalyDetectionScreenState extends State<AnomalyDetectionScreen> {
  late double temperature = 0.0;
  late double humidity = 0.0;
  late double rainfall = 0.0;
  late int pressure = 0;
  late double altitude = 0.0;
  late double actualsolar = 0.0;
  late double predictedsolar = 0;
  late bool anomalyDetected = false;
  late bool detectrain = false;
  late int time = 0;
  late double pressureforrain = 0.0;
  late String rain = "";

  @override
  void initState() {
    super.initState();
    fetchData().then((List<dynamic> data) {
      setState(() {
        temperature = data[3];
        humidity = data[4];
        pressure = data[5];
        pressureforrain = pressure * 0.01;
        altitude = data[6];
        actualsolar = data[7];
        List<String> parts1 = data[2].split('T');
        String timeString = parts1[1];
        List<String> parts = timeString.split(':');
        int t = int.parse(parts[0]) + 5;
        if (t < 12) {
          time = 2;
        } else if (t < 16) {
          time = 3;
        } else {
          time = 1;
        }
        predictedsolar = 0.20166982193992739 * temperature -
            0.03494968000471072 * humidity -
            0.0021908635460777086 * pressure -
            0.023154358094584757 * altitude +
            0.6438950521147927 * time +
            220.6270736084843;
        detectAnomalies();
      });
    });
  }

  Future<List<dynamic>> fetchData() async {
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

  void detectAnomalies() {
    anomalyDetected = false;
    rainfall = -0.62655 * temperature - 0.1 * humidity + 0.27626 * pressureforrain - 242.65440;
    if (actualsolar < 0.3 * predictedsolar) {
      anomalyDetected = true;
    }
    if (anomalyDetected) {
      showAnomalyDialog();
    }
    if (rainfall > 12.0) {
      showRainDialog();
    }
    setState(() {});
  }

  Color getRainColor(double rainfall) {
    if (rainfall > 12.0) {
      rain = "raining";
      return Colors.blue; // Heavy Rain
    } else if (rainfall > 10.0) {
      rain = "slight chances of rain";
      return Colors.lightBlueAccent; // Moderate Rain
    } else {
      rain = "not raining";
      return Colors.orange; // No Rain
    }
  }

  void showAnomalyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Anomaly Detected'),
          content: Text('Anomaly has been detected.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showRainDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rainfall Detected'),
          content: Text('Raining..'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Anomaly Detection and Rainfall Prediction'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: anomalyDetected ? Colors.red[200] : Colors.green[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      anomalyDetected ? Icons.error : Icons.check_circle,
                      color: Colors.white,
                      size: 40,
                    ),
                    Text(
                      anomalyDetected ? 'Anomaly Detected' : 'No Anomaly Detected',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: getRainColor(rainfall),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.cloud,
                      color: Colors.white,
                      size: 40,
                    ),
                    Text(
                      'Rainfall: $rain',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
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
      ),
    );
  }
}


