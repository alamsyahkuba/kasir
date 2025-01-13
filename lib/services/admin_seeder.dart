import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future seedDataOnce() async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('users')
        .select()
        .eq('email', 'administrator@gmail.com')
        .maybeSingle();

    if (response == null) {
      final hashedPassword = BCrypt.hashpw('admin123', BCrypt.gensalt());
      await supabase.from('users').insert({
        'email': 'administrator@gmail.com',
        'username': 'Administrator',
        'password': hashedPassword,
        'role': 'admin',
      });
    } else {
      // ignore: avoid_print
      print('User dengan email administrator@gmail.com sudah ada.');
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error $e");
  }
}
