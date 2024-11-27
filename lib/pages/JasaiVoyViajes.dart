import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:jasaivoy/pages/InformacionPasajeros.dart';
import 'package:jasaivoy/pages/ViajesRegistradosPasajeros.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:jasaivoy/pages/models/user_model.dart' as userModel;
import 'package:jasaivoy/pages/models/auth_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(token: ''),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

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

  bool _isRideAccepted = false;
  Map<String, dynamic>? _driverData;
  TextEditingController startController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  int _selectedIndex = 0;
  bool _isRequestingRide = false;
  late IO.Socket socket;
  userModel.UserModel? user;
  bool _isDriverInfoAvailable =
      false; // Indica si mostrar el botón del conductor
  Map<String, dynamic>? _driverInfo;

  final String apiKey = "AIzaSyABT2XqfABLKZHWlxg_IF412hYYOqZWYAk";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeSocket();
    _loadUserData();
  }

  void _getCurrentLocation() async {
    var currentLocation = await location.getLocation();
    _startLatLng =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);
    _setMarkerAndAddress(_startLatLng!, startController, isStartLocation: true);
  }

  void _loadUserData() {
    // Obtener la información del usuario desde AuthModel y castear al modelo necesario
    final authUser = Provider.of<AuthModel>(context, listen: false).currentUser;
    if (authUser != null) {
      user = userModel.UserModel(
        id: authUser.id,
        nombre: authUser.nombre,
        correo: authUser.correo,
        telefono: authUser.telefono,
        foto: authUser.foto,
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Modifica el botón de "OK" en el diálogo
  void _showRideAcceptedDialog({
    required String driverName,
    required String phoneNumber,
    required String driverMatricula,
    required Map<String, dynamic> initialLocation,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Viaje Aceptado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Conductor: $driverName',
                  style: const TextStyle(fontSize: 16)),
              Text('Teléfono: $phoneNumber',
                  style: const TextStyle(fontSize: 16)),
              Text('Matricula: $driverMatricula',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Ubicación inicial:',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Latitud: ${initialLocation['latitude']}\nLongitud: ${initialLocation['longitude']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // Actualiza el estado con la información del conductor
                  _isDriverInfoAvailable = true;
                  _driverInfo = {
                    'name': driverName,
                    'phone': phoneNumber,
                    'matricula': driverMatricula,
                  };
                });
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

// Botón que cambia dinámicamente
  Widget _buildDynamicButton() {
    if (_isDriverInfoAvailable && _driverInfo != null) {
      // Botón que abre el modal con la información del conductor
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _showDriverInfoModal,
          child: const Text('Ver Información del Conductor'),
        ),
      );
    } else {
      // Botón original para solicitar el viaje
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isRequestingRide ? null : _requestRide,
          child: _isRequestingRide
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Text('Solicitar Viaje'),
        ),
      );
    }
  }

// Método para mostrar el modal con la información del conductor
  void _showDriverInfoModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Información del Conductor',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Conductor: ${_driverInfo?['name']}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Teléfono: ${_driverInfo?['phone']}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Matricula: ${_driverInfo?['matricula']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el modal
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTripSummary({
    required String message,
    required int duration,
    required Map<String, dynamic> startDetails,
    required Map<String, dynamic> destinationDetails,
  }) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Obliga al usuario a interactuar con el diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resumen del Viaje'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Duración: $duration minutos',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Inicio:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Latitud: ${startDetails['latitude']}\nLongitud: ${startDetails['longitude']}',
              ),
              const SizedBox(height: 8),
              Text(
                'Destino:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Latitud: ${destinationDetails['latitude']}\nLongitud: ${destinationDetails['longitude']}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _resetState(); // Restablecer el estado
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Método para restablecer
  void _resetState() {
    setState(() {
      _isRideAccepted = false;
      _isDriverInfoAvailable = false;
      _driverData = null;
      _startMarker = null;
      _destinationMarker = null;
      _routePolyline = null;
      startController.clear();
      destinationController.clear();
    });
  }

  void _initializeSocket() {
    socket = IO.io('http://35.175.159.211:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Conectar al servidor WebSocket
    socket.connect();

    // Escuchar eventos de conexión
    socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    // Escuchar solicitud de viaje aceptada
    socket.on('rideAccepted', (data) {
      setState(() {
        _isRideAccepted = true; // El viaje ha sido aceptado
        _driverData = data; // Almacenar los datos del conductor
      });

      // Mostrar el cuadro de diálogo
      _showRideAcceptedDialog(
        driverName: data['driverInfo']['name'],
        phoneNumber: data['driverInfo']['phone'],
        driverMatricula: data['driverInfo']['matricula'],
        initialLocation: data['driverLocation'],
      );
    });

    // Escuchar finalización del viaje
    socket.on('tripEnded', (data) {
      print('Viaje finalizado: $data');

      // Mostrar un resumen del viaje y restablecer el estado
      _showTripSummary(
        message: data['message'],
        duration: data['duration'],
        startDetails: data['details']['start'],
        destinationDetails: data['details']['destination'],
      );
    });

    // Escuchar cuando el socket se desconecta
    socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });
  }

  Future<void> _setMarkerAndAddress(
      LatLng position, TextEditingController controller,
      {required bool isStartLocation}) async {
    setState(() {
      if (isStartLocation) {
        _startMarker = Marker(
          markerId: const MarkerId('start'),
          position: position,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
        _startLatLng = position;
      } else {
        _destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
        _destinationLatLng = position;
      }
    });

    String address = await _getAddressFromLatLng(position);
    setState(() {
      controller.text = address;
    });

    if (_startLatLng != null && _destinationLatLng != null) {
      await _getRoutePolyline();
    }
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      } else {
        return "Dirección no disponible";
      }
    } else {
      return "Error al obtener dirección";
    }
  }

  Future<void> _getRoutePolyline() async {
    if (_startLatLng == null || _destinationLatLng == null) return;

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
      }
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

  Future<void> _requestRide() async {
    if (_startLatLng == null || _destinationLatLng == null || user == null)
      return;

    setState(() {
      _isRequestingRide = true;
    });

    try {
      // Emitir solicitud de viaje al servidor WebSocket
      socket.emit('requestRide', {
        'start': {
          'latitude': _startLatLng!.latitude,
          'longitude': _startLatLng!.longitude,
        },
        'destination': {
          'latitude': _destinationLatLng!.latitude,
          'longitude': _destinationLatLng!.longitude,
        },
        'passengerName': user!.nombre,
        'phoneNumber': user!.telefono,
        'passengerId': socket.id,
      });

      // Enviar datos del viaje al webhook
      await _sendDataToWebhook();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Solicitud de viaje enviada. Esperando conductor...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isRequestingRide = false;
      });
    }
  }

  Future<void> _sendDataToWebhook() async {
    final url = Uri.parse(
        'http://35.175.159.211:4000/webhook'); // Cambia la URL por la de tu webhook
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'start': {
          'latitude': _startLatLng!.latitude,
          'longitude': _startLatLng!.longitude,
        },
        'destination': {
          'latitude': _destinationLatLng!.latitude,
          'longitude': _destinationLatLng!.longitude,
        },
        'passengerName': user!.nombre,
        'phoneNumber': user!.telefono,
      }),
    );

    if (response.statusCode == 200) {
      print('Datos enviados al webhook correctamente');
    } else {
      print('Error al enviar datos al webhook: ${response.statusCode}');
    }
  }

  void _handleEmergency() {
    socket.emit('emergency', {
      'passengerId': user!.id,
      'location': {
        'latitude': _startLatLng!.latitude,
        'longitude': _startLatLng!.longitude,
      },
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Emergencia notificada!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: CircleAvatar(
                radius: 20,
                backgroundImage:
                    user?.foto != null ? NetworkImage(user!.foto!) : null,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ),
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
                hintText: 'Seleccione su ubicación',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.red),
                hintText: 'Seleccione su destino',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                            title:
                                const Text('Establecer como ubicación inicial'),
                            onTap: () {
                              Navigator.pop(context);
                              _setMarkerAndAddress(latLng, startController,
                                  isStartLocation: true);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: const Text('Establecer como destino'),
                            onTap: () {
                              Navigator.pop(context);
                              _setMarkerAndAddress(
                                  latLng, destinationController,
                                  isStartLocation: false);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_startLatLng != null && _destinationLatLng != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isDriverInfoAvailable
                      ? _showDriverInfoModal // Si hay información del conductor, muestra el modal
                      : (_isRequestingRide
                          ? null
                          : _requestRide), // De lo contrario, solicita un viaje
                  child: _isDriverInfoAvailable
                      ? const Text('Ver Información del Conductor')
                      : (_isRequestingRide
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Solicitar Viaje')),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar2.png'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar3.png'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar4.png'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar5.png'),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });

          // Maneja la redirección con if
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GraphScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ViajesRegistradosScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graficas'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Pantalla de Graficas'),
      ),
    );
  }
}
