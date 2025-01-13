import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aplikasi_kasir/pages/login.dart';

final supabase = Supabase.instance.client;

Future auth(String email, String password) async {
  try {
    final response = await supabase
        .from('users')
        .select('password')
        .eq('email', email)
        .maybeSingle();

    final hashedPassword = response?['password'];

    if (BCrypt.checkpw(password, hashedPassword)) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error: $e");
    return false;
  }
}

Future<void> logOut(BuildContext context) async {
  await supabase.auth.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}
