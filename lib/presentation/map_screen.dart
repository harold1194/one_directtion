import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:one_directtion/widget/my_input.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final start = TextEditingController();
  final end = TextEditingController();
  bool isVisible = false;
  List<LatLng> routepoints = [LatLng(52.05884, -1.345583)];
  double distance = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
        title: const Text("Routes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyInput(textController: start, hintext: 'Enter Starting Point'),
              const SizedBox(height: 15),
              MyInput(textController: end, hintext: 'Enter End Point'),
              const SizedBox(height: 15),
              Text(
                'Distance: ${distance.toStringAsFixed(2)} km',
                style: const TextStyle(
                    fontSize: 35,
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                height: 75,
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    List<Location> start_l =
                        await locationFromAddress(start.text);
                    List<Location> end_l = await locationFromAddress(end.text);

                    var v1 = start_l[0].latitude;
                    var v2 = start_l[0].longitude;
                    var v3 = end_l[0].latitude;
                    var v4 = end_l[0].longitude;

                    double distance = calculateDistance(v1, v2, v3, v4);
                    var url = Uri.parse(
                        'http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
                    var response = await http.get(url);
                    print(response.body);

                    setState(() {
                      routepoints = [];

                      // this will reset the distance
                      distance = 0.0;
                      var router = jsonDecode(response.body)['routes'][0]
                          ['geometry']['coordinates'];
                      for (int i = 0; i < router.length; i++) {
                        var reep = router[i].toString();
                        reep = reep.replaceAll("[", "");
                        reep = reep.replaceAll("]", "");
                        var lat1 = reep.split(',');
                        var long1 = reep.split(',');
                        var lat = double.parse(lat1[1]);
                        var long = double.parse(long1[0]);
                        routepoints.add(
                          LatLng(
                            double.parse(lat1[1]),
                            double.parse(long1[0]),
                          ),
                        );

                        if (i > 0) {
                          var prevLat =
                              double.parse(router[i - 1][1].toString());
                          var prevLong =
                              double.parse(router[i - 1][0].toString());
                          var currDistance = const Distance().as(
                              LengthUnit.Meter,
                              LatLng(lat, long),
                              LatLng(prevLat, prevLong));
                          distance += currDistance;
                        }
                        this.distance = distance;
                        isVisible = !isVisible;
                        print(routepoints);
                      }
                    });
                  },
                  child: const Text('Press'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 500,
                width: 400,
                child: Visibility(
                  visible: isVisible,
                  child: FlutterMap(
                    options: MapOptions(
                      center: routepoints[0],
                      zoom: 10,
                    ),
                    nonRotatedChildren: [
                      AttributionWidget.defaultWidget(
                        source: 'OpenStreetMap contributors',
                        onSourceTapped: null,
                      ),
                    ],
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      PolylineLayer(
                        polylineCulling: false,
                        polylines: [
                          Polyline(
                              points: routepoints,
                              color: Colors.red,
                              strokeWidth: 9)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
