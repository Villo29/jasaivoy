import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:jasaivoy/pages/models/auth_model.dart';

class ViajesRegistradosScreen extends StatefulWidget {
  const ViajesRegistradosScreen({super.key});

  @override
  _ViajesRegistradosScreenState createState() =>
      _ViajesRegistradosScreenState();
}

class _ViajesRegistradosScreenState extends State<ViajesRegistradosScreen> {
  List<dynamic> viajes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchViajes();
  }

  Future<void> fetchViajes() async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final fetchedViajes = await authModel.fetchViajes();
      setState(() {
        viajes = fetchedViajes;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los viajes:');
      setState(() {
        isLoading = false;
      });
    }
  }

  final Map<String, Widget Function(BuildContext, dynamic)> views = {
    "mapView": (context, viaje) => _buildTravelCard(
          context,
          passengerName: viaje['passenger_name'],
          startCoordinates: LatLng(
            double.parse(viaje['start_latitude']),
            double.parse(viaje['start_longitude']),
          ),
          destinationCoordinates: LatLng(
            double.parse(viaje['destination_latitude']),
            double.parse(viaje['destination_longitude']),
          ),
        ),
    "listView": (context, viaje) => ListTile(
          title: Text("Pasajero: ${viaje['passenger_name']}"),
          subtitle: Text(
              "Inicio: ${viaje['start_latitude']}, ${viaje['start_longitude']}\nDestino: ${viaje['destination_latitude']}, ${viaje['destination_longitude']}"),
        ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes registrados'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : viajes.isEmpty
              ? const Center(
                  child: Text('No hay viajes registrados.'),
                )
              : ListView.builder(
                  itemCount: viajes.length,
                  itemBuilder: (context, index) {
                    final viaje = viajes[index];

                    // Puedes cambiar "mapView" a "listView" para renderizar otra vista.
                    return views["mapView"]!(context, viaje);
                  },
                ),
    );
  }

  static Widget _buildTravelCard(BuildContext context,
      {required String passengerName,
      required LatLng startCoordinates,
      required LatLng destinationCoordinates}) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pasajero: $passengerName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: startCoordinates,
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('start'),
                    position: startCoordinates,
                    infoWindow: const InfoWindow(title: 'Inicio del viaje'),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: destinationCoordinates,
                    infoWindow: const InfoWindow(title: 'Destino del viaje'),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
