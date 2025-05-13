import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';

class AuthService {
  bool isLoggedIn = false; // Variable para almacenar el estado de autenticación
  User? currentUser;

  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/users';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/users';
    } else {
      return 'http://localhost:9000/api/users';
    }
  }

  //login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final body = json.encode({'email': email, 'password': password});

    try {
      print("enviant solicitud post a: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("Resposta rebuda amb codi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        currentUser = User.fromJson(userData); //guardem l'usuari actual
        isLoggedIn = true;
        return userData;
      } else {
        return {'error': 'email o contrasenya incorrectes'};
      }
    } catch (e) {
      print("Error al fer la solicitud: $e");
      return {'error': 'Error de connexió'};
    }
  }

  //mètode per actualitzar l'usuari
  Future<Map<String, dynamic>> updateUser(String id, User updatedUser) async {
    final url = Uri.parse('$_baseUrl/$id');
    
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedUser.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        currentUser = updatedUser; // Actualizamos el usuario actual
        return {'success': true, 'data': updatedData};
      } else {
        return {'error': 'Error al actualizar usuario'};
      }
    } catch (e) {
      return {'error': 'Error de conexión: $e'};
    }
  }

  //mètode per canviar la contrasenya
  Future<Map<String, dynamic>> changePassword(String id, String newPassword) async {
    if (currentUser == null) {
      return {'error': 'No hay usuario conectado'};
    }
    
    try {
      final updatedUser = User(
        id: currentUser!.id,
        name: currentUser!.name,
        age: currentUser!.age,
        email: currentUser!.email,
        password: newPassword,
      );
      
      final result = await updateUser(id, updatedUser);
      return result;
    } catch (e) {
      return {'error': 'Error al cambiar contraseña: $e'};
    }
  }

  void logout() {
    isLoggedIn = false; // Cambia el estado de autenticación a no autenticado
    currentUser = null;
    print("Sessió tancada");
  }
}
