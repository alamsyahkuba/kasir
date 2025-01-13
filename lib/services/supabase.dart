import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'https://kgrbanqnlpahtqpmtqza.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtncmJhbnFubHBhaHRxcG10cXphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMjU2NzYsImV4cCI6MjA1MTcwMTY3Nn0.8dkux--PjtKfLazrUrOSI7Eh7E7mMHKYNnzBZhrquwI',
  );
}
