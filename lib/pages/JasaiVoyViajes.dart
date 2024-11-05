import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  Location location = Location();
  Marker? _startMarker;
  Marker? _destinationMarker;
  LatLng? _startLatLng;
  LatLng? _destinationLatLng;
  Polyline? _routePolyline;

  TextEditingController startController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    var currentLocation = await location.getLocation();
    setState(() {
      _startLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _startMarker = Marker(
        markerId: const MarkerId('start'),
        position: _startLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      startController.text = "${_startLatLng!.latitude}, ${_startLatLng!.longitude}";
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _selectLocation(LatLng latLng, bool isStartLocation) async {
    setState(() {
      if (isStartLocation) {
        _startLatLng = latLng;
        _startMarker = Marker(
          markerId: const MarkerId('start'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
        _getAddressFromLatLng(latLng, true); // Obtener dirección para el marcador de inicio
      } else {
        _destinationLatLng = latLng;
        _destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
        _getAddressFromLatLng(latLng, false); // Obtener dirección para el marcador de destino
      }
    });

    // Llama a la función para obtener la ruta si se establecieron ambas ubicaciones
    if (_startLatLng != null && _destinationLatLng != null) {
      await _getRoutePolyline();
    }
  }

  Future<void> _getRoutePolyline() async {
    if (_startLatLng == null || _destinationLatLng == null) return;

    const apiKey = "AIzaSyABT2XqfABLKZHWlxg_IF412hYYOqZWYAk";
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?origin=${_startLatLng!.latitude},${_startLatLng!.longitude}&destination=${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}&key=$apiKey",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        final polylineCoordinates = _decodePolyline(polylinePoints);

        setState(() {
          _routePolyline = Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          );
        });
      } else {
        print("No se encontraron rutas.");
      }
    } else {
      print("Error al obtener la ruta: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng, bool isStartLocation) async {
    const apiKey = "AIzaSyABT2XqfABLKZHWlxg_IF412hYYOqZWYAk"; // Cambia esto por tu clave
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        String address = data['results'][0]['formatted_address'];
        setState(() {
          if (isStartLocation) {
            startController.text = address; // Mostrar dirección en el campo de texto de inicio
          } else {
            destinationController.text = address; // Mostrar dirección en el campo de texto de destino
          }
        });
      } else {
        // Si no se encuentra una dirección, muestra las coordenadas
        setState(() {
          if (isStartLocation) {
            startController.text = "${latLng.latitude}, ${latLng.longitude}";
          } else {
            destinationController.text = "${latLng.latitude}, ${latLng.longitude}";
          }
        });
      }
    } else {
      print("Error al obtener la dirección: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('assets/perfilFoto.png'),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: startController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                hintText: 'Seleccione en el mapa su ubicación',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.red),
                hintText: 'Seleccione en el mapa su destino',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _startLatLng ?? const LatLng(16.621537, -93.099800),
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: {
                  if (_startMarker != null) _startMarker!,
                  if (_destinationMarker != null) _destinationMarker!,
                },
                polylines: {
                  if (_routePolyline != null) _routePolyline!,
                },
                onTap: (LatLng latLng) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Establecer como ubicación inicial'),
                          onTap: () {
                            Navigator.pop(context);
                            _selectLocation(latLng, true);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: const Text('Establecer como destino'),
                          onTap: () {
                            Navigator.pop(context);
                            _selectLocation(latLng, false);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
