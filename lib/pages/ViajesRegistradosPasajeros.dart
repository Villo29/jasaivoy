import 'package:flutter/material.dart';
import 'package:jasaivoy/pages/JasaiVoyViajes.dart';
import 'package:jasaivoy/pages/InformacionPasajeros.dart';

class ViajesRegistradosScreen extends StatefulWidget {
  const ViajesRegistradosScreen({super.key});

  @override
  _ViajesRegistradosScreenState createState() => _ViajesRegistradosScreenState();
}

class _ViajesRegistradosScreenState extends State<ViajesRegistradosScreen> {
  int _selectedIndex = 0; // Para mantener el índice seleccionado

  void _onItemTapped(int index) {
    if (index == 4) {
      // Si el índice es 4, navega a la pantalla de perfil
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Viajes registrados',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage('assets/ImagenPasajero.png'),
            radius: 20,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTravelCard(
              context,
              title: 'UPCH-Dpto. Monacos',
              origen: 'UPCH.',
              destino: 'Dpto.Monaco',
              fecha: '22/10/2024',
              hora: '14:00',
              precio: 10.00,
            ),
            const SizedBox(height: 10),
            _buildTravelCard(
              context,
              title: 'Parque Sta Anita-Mercado',
              origen: 'Parque Sta.Anita',
              destino: 'Mercado',
              fecha: '22/10/2024',
              hora: '14:00',
              precio: 20.00,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.black),
                label:
                    const Text('Nuevo viaje', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
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
            icon: Image.asset(
              'assets/icons/IcoNavBar1.png',
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/IcoNavBar2.png',
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/IcoNavBar3.png',
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/IcoNavBar4.png',
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/IcoNavBar5.png',
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Llama a la función _onItemTapped al seleccionar un ítem
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  Widget _buildTravelCard(BuildContext context,
      {required String title,
      required String origen,
      required String destino,
      required String fecha,
      required String hora,
      required double precio}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Origen', style: TextStyle(color: Colors.grey)),
                    Text(origen, style: const TextStyle(color: Colors.red)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Destino', style: TextStyle(color: Colors.grey)),
                    Text(destino, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fecha', style: TextStyle(color: Colors.grey)),
                Text('Hora', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fecha, style: const TextStyle(color: Colors.red)),
                Text(hora, style: const TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$ ${precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
