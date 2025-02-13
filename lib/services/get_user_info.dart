import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future getUserInfo() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  final response = await supabase
      .from('users')
      .select('username, role, email')
      .eq('id', userId as Object)
      .maybeSingle();

  final user = response?['username'] as String?;
  final email = response?['email'] as String?;
  final role = response?['role'] as String?;
  return {'username': user, 'email': email, 'role': role};
}
