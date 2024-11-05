import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jasaivoy/pages/models/user_model.dart';

class AuthModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _token = '';
  String _userId = '';
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  String get token => _token;  // Getter para token
  String get userId => _userId;  // Getter para userId

  AuthModel();

  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(String correo, String contrasena) async {
    var url = Uri.parse('http://67.202.4.38:3000/api/usuarios/login');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _token = data['token'];
      _userId = data['usuario']['_id'];
      _isLoggedIn = true;
      await fetchUserData();
      notifyListeners();
    } else {
      throw Exception('Failed to log in');
    }
  }

  void logout() {
    _isLoggedIn = false;
    _token = '';
    _userId = '';
    _currentUser = null;
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    var url = Uri.parse('http://67.202.4.38:3000/api/usuarios/${_userId}');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      var userData = json.decode(response.body);
      _currentUser = UserModel.fromJson(userData);
      notifyListeners();
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Método para actualizar los datos del usuario
  Future<void> updateUserData(String nombre, String correo, String contrasena, String telefono) async {
    var url = Uri.parse('http://67.202.4.38:3000/api/usuarios/${_userId}');
    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        'telefono': telefono
      }),
    );

    if (response.statusCode == 200) {
      await fetchUserData(); // Refrescar los datos del usuario
      notifyListeners();
    } else {
      throw Exception('Failed to update user data');
    }
  }

  // Método para eliminar la cuenta del usuario
  Future<void> deleteUser() async {
    var url = Uri.parse('http://67.202.4.38:3000/api/usuarios/${_userId}');
    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      logout(); // Asegúrate de que este método efectivamente limpia los datos del usuario y notifica a los listeners.
    } else {
      throw Exception('Failed to delete user with status: ${response.statusCode}');
    }
  }
}
