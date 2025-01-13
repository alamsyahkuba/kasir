import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  final response = await supabase
      .from('users')
      .select('username')
      .eq('id', userId as Object)
      .maybeSingle();

  final username = response?['username'] as String?;
  return username;
}
