import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final Box _usersBox = Hive.box('users');
  final Box _authBox = Hive.box('auth');

  Map<String, dynamic>? get currentUser {
    final email = _authBox.get('current_user_email');
    if (email == null) return null;
    final userData = _usersBox.get(email);
    if (userData == null) return null;
    return Map<String, dynamic>.from(userData);
  }

  bool get isLoggedIn => _authBox.get('current_user_email') != null;

  String? register({required String name, required String email, required String password}) {
    final cleanEmail = email.trim().toLowerCase();
    if (_usersBox.containsKey(cleanEmail)) {
      return 'Email sudah terdaftar';
    }
    final userData = {
      'name': name.trim(),
      'email': cleanEmail,
      'password': password,
    };
    _usersBox.put(cleanEmail, userData);
    _authBox.put('current_user_email', cleanEmail);
    notifyListeners();
    return null; // success
  }

  String? login({required String email, required String password}) {
    final cleanEmail = email.trim().toLowerCase();
    if (!_usersBox.containsKey(cleanEmail)) {
      return 'Email belum terdaftar';
    }
    final userData = Map<String, dynamic>.from(_usersBox.get(cleanEmail));
    if (userData['password'] != password) {
      return 'Password salah';
    }
    _authBox.put('current_user_email', cleanEmail);
    notifyListeners();
    return null; // success
  }

  Future<void> logout() async {
    await _authBox.delete('current_user_email');
    notifyListeners();
  }
}
