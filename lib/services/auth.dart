import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_kasir/pages/login.dart';

final supabase = Supabase.instance.client;

Future auth(String email, String password) async {
  try {
    final response = await supabase
        .from('users')
        .select('id, password')
        .eq('email', email)
        .maybeSingle();

    if (response == null) {
      return "email_not_found";
    }
    final hashedPassword = response!['password'];
    final userId = response['id'].toString();

    if (BCrypt.checkpw(password, hashedPassword)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);

      return "success";
    } else {
      return "wrong_password";
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error: $e");
    return false;
  }
}

Future<void> logOut(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}
