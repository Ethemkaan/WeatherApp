import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather_app/search_page.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/widgets/daily_weather_card.dart';
import 'package:weather_app/widgets/loading_widget.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = 'Ankara';
  double? temp;
  final String key = '1c6f936ef8155015709e55b3758add2a';
  var locationData;
  String code = 'c';
  Position? devicePosition;
  String? icon;
  List<String> icons = ['01d', '01d', '01d', '01d', '01d'];
  List<String> dates = [];
  List<double> temparatures = [20.0, 20.0, 20.0, 20.0, 20.0];

  Future<void> getLocationData() async {
    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key'
        '&units=metric'));
    final locationDataParsed = jsonDecode(locationData.body);
    setState(() {
      temp = locationDataParsed['main']['temp'];
      location = locationDataParsed['name'];
      code = locationDataParsed['weather'][0]['main'];
      icon = locationDataParsed['weather'][0]['icon'];
    });
  }

  Future<void> getLocationDataWlatlong() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key'
          '&units=metric'));
      final locationDataParsed = jsonDecode(locationData.body);
      setState(() {
        temp = locationDataParsed['main']['temp'];
        location = locationDataParsed['name'];
        code = locationDataParsed['weather'][0]['main'];
        icon = locationDataParsed['weather'][0]['icon'];
      });
    }
  }

  Future<void> getDeviceLocation() async {
    devicePosition = await _determinePosition();
  }

  Future<void> getDailyForecastByLotLong() async {
    var forecast = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key'
        '&units=metric'));
    var forecastDataParsed = jsonDecode(forecast.body);
    temparatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      temparatures.add(forecastDataParsed['list'][7]['main']['temp']);
      temparatures.add(forecastDataParsed['list'][15]['main']['temp']);
      temparatures.add(forecastDataParsed['list'][23]['main']['temp']);
      temparatures.add(forecastDataParsed['list'][31]['main']['temp']);
      temparatures.add(forecastDataParsed['list'][39]['main']['temp']);

      icons.add(forecastDataParsed['list'][7]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][15]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][23]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][31]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][39]['weather'][0]['icon']);

      dates.add(forecastDataParsed['list'][7]['dt_txt']);
      dates.add(forecastDataParsed['list'][15]['dt_txt']);
      dates.add(forecastDataParsed['list'][23]['dt_txt']);
      dates.add(forecastDataParsed['list'][31]['dt_txt']);
      dates.add(forecastDataParsed['list'][39]['dt_txt']);
    });
  }

  Future<void> getDailyForecastByLocation() async {
    var forecast = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key'
        '&units=metric'));
    var forecastDataParsed = jsonDecode(forecast.body);
    temparatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        temparatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  void getInitData() async {
    await getDeviceLocation();
    await getLocationDataWlatlong();
    await getDailyForecastByLotLong();
  }

  @override
  void initState() {
    getInitData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/$code.jpg'), fit: BoxFit.cover)),
      child: (temp == null || devicePosition == null ||icons.isEmpty || dates.isEmpty || temparatures.isEmpty)
          ? const LoadingWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Image.network(
                          'https://openweathermap.org/img/wn/$icon@4x.png'),
                    ),
                    Text(
                      '$temp°C',
                      style:
                          TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            onPressed: () async {
                              final selectedCity = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(),
                                  ));
                              location = selectedCity;
                              getLocationData();
                              getDailyForecastByLocation();
                            },
                            icon: Icon(Icons.search))
                      ],
                    ),
                     IconButton(onPressed: () {
                      getInitData();
                    }, icon: Icon(Icons.my_location, size: 50,)),
                    SizedBox(
                      height: 50,
                    ),
                    buildWeatherCard(context)
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildWeatherCard(BuildContext context) {
    List<DailyWeather> cards = [
    ];

    for (int i = 0; i < 5; i++) {
      cards.add(
          DailyWeather(icon: icons[i], temp: temparatures[i], date: dates[i]));
    }
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(scrollDirection: Axis.horizontal, children: cards),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}


