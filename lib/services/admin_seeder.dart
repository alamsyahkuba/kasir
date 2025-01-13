import 'package:supabase_flutter/supabase_flutter.dart';

Future seedDataOnce() async {
  final supabase = SupabaseClient('https://kgrbanqnlpahtqpmtqza.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtncmJhbnFubHBhaHRxcG10cXphIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNjEyNTY3NiwiZXhwIjoyMDUxNzAxNjc2fQ.J9aUg9_GBs4qK2vtsGQXs2PI0rAo4V9ji0xJb2FSNyI');

  final response = await supabase.auth.admin.listUsers();

  final existingUser = response?.firstWhere(
    (users) => users.email == 'administrator@gmail.com',
  );

  if (existingUser == null) {
    try {
      await supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: 'administrator@gmail.com',
          password: 'admin123',
          userMetadata: {
            'name': 'Administrator',
            'role': 'administrator',
          },
          emailConfirm: true,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print("Error $e");
    }
  } else {
    // ignore: avoid_print
    print('User dengan email administrator@gmail.com sudah ada.');
  }
}
