import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // Email Field
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.red),
                labelText: 'Correo',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Password Field
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: Colors.red),
                labelText: 'Contraseña',
                suffixIcon: Icon(Icons.visibility_off_outlined),
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Acción para olvidar contraseña
                },
                child: const Text(
                  '¿Has olvidado tu contraseña?',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Login Button
            ElevatedButton(
              onPressed: () {
                // Acción para iniciar sesión
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent, // Color del botón
                minimumSize: const Size(double.infinity, 50), // Tamaño del botón
              ),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            // Registration Links
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Pasajero?'),
                SizedBox(width: 5),
                Text(
                  'Registrate',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Conductor?'),
                SizedBox(width: 5),
                Text(
                  'Registrate',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // OR Divider
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('O'),
                ),
                Expanded(child: Divider()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
