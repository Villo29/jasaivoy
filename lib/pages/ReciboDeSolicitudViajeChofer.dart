import 'package:flutter/material.dart';
import 'package:jasaivoy/pages/conductorapartado.dart';
import 'package:jasaivoy/pages/RegistroDeUnidad.dart';

class ReciboDeSolicitudViajeChoferScreen extends StatefulWidget {
  @override
  _ReciboDeSolicitudViajeChoferScreenState createState() =>
      _ReciboDeSolicitudViajeChoferScreenState();
}

class _ReciboDeSolicitudViajeChoferScreenState
    extends State<ReciboDeSolicitudViajeChoferScreen> {
  int _selectedIndex =
      0; // Agrega esta variable para manejar el índice seleccionado

  @override
  void initState() {
    super.initState();
    // Mostrar el diálogo cuando se construye la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSolicitudDialog();
    });
  }

  void _showSolicitudDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text('Solicitud de servicio de Carlos Cruz'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Punto de recogida: Calle Ejemplo, 123'),
              SizedBox(height: 8.0),
              Text('Destino: Avenida Ejemplo, 456'),
            ],
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Acción al aceptar el servicio
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Aceptar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Acción al rechazar el servicio
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Rechazar'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Función para manejar el cambio de ítem en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Redirige a la pantalla RegistroUnidadPage si el índice es 3
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RegistroUnidadPage(), // Asegúrate de importar esta clase correctamente
          ),
        );
      }

      // Redirige a la pantalla ProfileScreenDriver si el índice es 4
      if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreenDriver(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('J. Voy Viajes'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Pantalla de Solicitud de Servicio'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar1.png'),
            label: '',
          ),
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
        onTap: _onItemTapped, // Usar la función para manejar el tap
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
