import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:geolocator/geolocator.dart';


class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  String selectedCity = '';

  @override
  Widget build(BuildContext context) {
    return Container(
     decoration:const BoxDecoration(
       image: DecorationImage(image: AssetImage('assets/search.jpg'),fit:BoxFit.cover)
     ),
         child: Scaffold(
           backgroundColor:Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: TextField(
                  onChanged: (value) {
                    selectedCity = value;
                  },
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40),
                  decoration: InputDecoration(hintText: 'Şehir Seçiniz', border: OutlineInputBorder(borderSide: BorderSide.none)),
                ),
              ),
              ElevatedButton(onPressed: () async {
                var response = await http.get(Uri.parse( 'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=1c6f936ef8155015709e55b3758add2a'
                '&units=metric'));
                if(response.statusCode == 200){
                  Navigator.pop(context, selectedCity);
                }else{
               // _showMyDialog();
                  showTopSnackBar(
                    Overlay.of(context),
                    CustomSnackBar.error(
                      message:
                      "Something went wrong. Please check your location and try again",
                    ),
                  );
                }

              }, child:Text('Select City'))
            ],
          ),
        ),
    ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Not Found'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please select a valid location'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
