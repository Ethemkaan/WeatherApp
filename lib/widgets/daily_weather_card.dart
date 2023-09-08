
import 'package:flutter/material.dart';


class DailyWeather extends StatelessWidget {
  final String icon ;
  final double temp ;
  final String date;

  const DailyWeather({Key? key, required this.icon, required this.temp, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    String weekday = weekdays[DateTime.parse(date).weekday - 1];

    return Card(
      elevation: 2  ,
      color: Colors.transparent,
      child: SizedBox(
        height: 120,
        width: 100,
        child: Column(
          children: [
            Expanded(child: Image.network('https://openweathermap.org/img/wn/$icon.png')),
            Expanded(child:Text(
              '$temp°C',
              style:
              const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            )),
            Expanded(child: Text(weekday))
          ],
        ),
      ),
    );
  }
}
