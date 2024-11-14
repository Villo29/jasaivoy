import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile_pic.png'), // Imagen de perfil
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hola David 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bienvenido a Jasai',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileInfoRow('Nombre', 'David'),
            _buildProfileInfoRow('Apellido', 'Ruiz'),
            _buildProfileInfoRow('Número de teléfono', '968-122-4567'),
            _buildProfileInfoRow('CURP', 'DARU290502'),
            _buildProfileInfoRow('Correo electrónico', 'David@gmail.com'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Lógica para "Viajes realizados"
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 251, 246),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Viajes realizados',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Lógica para "Registro de unidad"
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 251, 246),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Registro de unidad',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Lógica para "Editar perfil"
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 251, 246),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Editar perfil',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.black),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
