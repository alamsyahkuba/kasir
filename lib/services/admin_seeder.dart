import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future seedDataOnce() async {
  final supabase = Supabase.instance.client;

  final response = supabase
      .from('users')
      .select('email')
      .eq('email', 'administrator@gmail.com');

  final hashedPassword = BCrypt.hashpw('admin123', BCrypt.gensalt());

  if (response == null) {
    try {
      await supabase.from('users').insert({
        'email': 'administrator@gmail.com',
        'username': 'Administrator',
        'password': hashedPassword,
        'role': 'admin',
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error $e");
    }
  } else {
    // ignore: avoid_print
    print('User dengan email administrator@gmail.com sudah ada.');
  }
}
