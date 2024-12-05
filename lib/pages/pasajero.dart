import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'JasaiVoyViajes.dart';

class PassengerRegistrationScreen extends StatefulWidget {
  const PassengerRegistrationScreen({super.key});

  @override
  _PassengerRegistrationScreenState createState() =>
      _PassengerRegistrationScreenState();
}

class _PassengerRegistrationScreenState
    extends State<PassengerRegistrationScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  bool _isPasswordVisible = false;
  File? _selectedImage;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await _requestStoragePermission();
    if (await Permission.storage.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, otorga permisos de almacenamiento')),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _registerUser() async {
    final String nombre = _nombreController.text;
    final String correo = _correoController.text;
    final String contrasena = _passwordController.text;
    final String telefono = _telefonoController.text;

    if (nombre.isNotEmpty &&
        correo.isNotEmpty &&
        contrasena.isNotEmpty &&
        telefono.isNotEmpty &&
        _selectedImage != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // Lista de campos a analizar
        final Map<String, String> fields = {
          'Nombre': nombre,
          'Correo': correo,
          'Teléfono': telefono,
        };
        for (final entry in fields.entries) {
          final analyzeUri = Uri.parse('http://35.175.159.211:5000/analyze');
          final analyzeResponse = await http.post(
            analyzeUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': entry.value}),
          );

          if (analyzeResponse.statusCode == 200) {
            final analyzeResult = jsonDecode(analyzeResponse.body);

            if (analyzeResult.containsKey('obscenas') &&
                analyzeResult['obscenas'] != null) {
              final int obscenas = analyzeResult['obscenas'];

              if (obscenas >= 3) {
                Navigator.of(context).pop();
                _showAlert(
                  title: 'Error en el campo',
                  message:
                      'Se detectaron palabras inapropiadas en el campo: ${entry.key}.',
                );
                return;
              }
            } else {
              Navigator.of(context).pop();
              _showAlert(
                title: 'Error al analizar',
                message:
                    'Error inesperado al analizar el texto del campo: ${entry.key}.',
              );
              return; // Detener el registro
            }
          } else {
            Navigator.of(context).pop(); // Cerrar el diálogo de carga
            throw Exception(
                'Error al analizar el texto: ${analyzeResponse.statusCode}');
          }
        }

        // Paso 2: Registrar al usuario si pasa el análisis
        Navigator.of(context).pop(); // Cerrar el diálogo de carga
        final uri = Uri.parse('http://35.175.159.211:3028/api/v1/users');
        final request = http.MultipartRequest('POST', uri);

        // Campos de texto
        request.fields['nombre'] = nombre;
        request.fields['correo'] = correo;
        request.fields['contrasena'] = contrasena;
        request.fields['telefono'] = telefono;

        request.files.add(await http.MultipartFile.fromPath(
          'imagenPath',
          _selectedImage!.path,
        ));

        final response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showAlert(
            title: 'Registro Exitoso',
            message: 'Tu registro fue completado con éxito.',
            isSuccess: true,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          );
        } else {
          final responseBody = await response.stream.bytesToString();
          _showAlert(
            title: 'Error en el registro',
            message: 'Error al registrar al usuario: $responseBody.',
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Cerrar el diálogo de carga
        _showAlert(
          title: 'Error en la conexión',
          message: 'Ocurrió un error al conectar con el servidor:',
        );
      }
    } else {
      _showAlert(
        title: 'Campos incompletos',
        message:
            'Todos los campos son obligatorios. Por favor, completa la información.',
      );
    }
  }

// Método para mostrar un AlertDialog
  void _showAlert({
    required String title,
    required String message,
    bool isSuccess = false,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/ImagenPasajero.png',
                      height: 120,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pasajero',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: _selectedImage == null
                      ? Column(
                          children: [
                            Icon(Icons.image, size: 100, color: Colors.grey),
                            const Text('Seleccionar Imagen'),
                          ],
                        )
                      : Image.file(
                          _selectedImage!,
                          height: 120,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/nombreIcono.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/arrobaCorreo.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  labelText: 'Correo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/contraseñaIcono.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.phone,
                        color: Color.fromARGB(255, 255, 12, 12)),
                  ),
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Regístrate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
