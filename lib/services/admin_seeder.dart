import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future seedDataOnce() async {
  // final supabase = SupabaseClient('https://kgrbanqnlpahtqpmtqza.supabase.co',
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtncmJhbnFubHBhaHRxcG10cXphIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNjEyNTY3NiwiZXhwIjoyMDUxNzAxNjc2fQ.J9aUg9_GBs4qK2vtsGQXs2PI0rAo4V9ji0xJb2FSNyI');

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
