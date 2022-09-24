import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'global.dart';
import 'map.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomePage(),
        'map': (context) => const MapScreen(),
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  requestPermission() async {
    await Permission.location.request();
  }

  @override
  initState() {
    super.initState();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/map_bg.jpg'),
              fit: BoxFit.cover,
              opacity: 0.2,
            )),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                    scale: 10,
                    child: Icon(Icons.location_on, color: Colors.green[700])),
                const SizedBox(height: 120),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green[700],
                    padding: const EdgeInsets.all(15),
                    textStyle: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    Geolocator.getPositionStream().listen((Position position) {
                      setState(() {
                        lat = position.latitude;
                        long = position.longitude;
                      });
                      Navigator.of(context).pushReplacementNamed('map');
                    });
                  },
                  child: const Text('Check Your Current Location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
