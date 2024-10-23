import 'package:flutter/material.dart';
import 'package:jasaivoy/pages/home.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jasai Voy - Login',
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
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // Campo de correo
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.red),
                labelText: 'Correo',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Campo de contraseña
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
            // Opción de contraseña olvidada
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Acción para recuperar contraseña
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  '¿Has olvidado tu contraseña?',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Botón de iniciar sesión
            ElevatedButton(
              onPressed: () {
                // Acción para iniciar sesión
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                );
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
            // Enlaces de registro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pasajero?'),
                const SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    // Acción para registro de pasajero
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPassengerScreen()),
                    );
                  },
                  child: const Text(
                    'Registrate',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Conductor?'),
                const SizedBox(width: 5),
                TextButton(
                  onPressed: () {
                    // Acción para registro de conductor
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterDriverScreen()),
                    );
                  },
                  child: const Text(
                    'Registrate',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Separador
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

// Pantalla de recuperación de contraseña
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: const Center(
        child: Text('Pantalla para recuperar contraseña'),
      ),
    );
  }
}

// Pantalla de registro de pasajero
class RegisterPassengerScreen extends StatelessWidget {
  const RegisterPassengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Pasajero'),
      ),
      body: const Center(
        child: Text('Pantalla de registro para pasajeros'),
      ),
    );
  }
}

// Pantalla de registro de conductor
class RegisterDriverScreen extends StatelessWidget {
  const RegisterDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Conductor'),
      ),
      body: const Center(
        child: Text('Pantalla de registro para conductores'),
      ),
    );
  }
}
