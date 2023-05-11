import 'package:blokus/pages/game_board_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // ! TODO: REPLACE TO PRODUCTION SERVER AND HIDE SECRETS
  await Supabase.initialize(
    url: 'https://igtfbjzlpverlfzsavno.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlndGZianpscHZlcmxmenNhdm5vIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODE1MzI1OTAsImV4cCI6MTk5NzEwODU5MH0.F-TEWzGfwOFZaXMOoKDQphAsp1aDJmF-7edX-R34Ziw',
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 40),
  );
  runApp(const MyApp());
}

SupabaseClient supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blokus',
      home: GameBoardPage(
        supabase: supabase,
        debug: true,
      ),
    );
  }
}
