import 'package:blokus/pages/game_board_page.dart';
import 'package:blokus/pages/login_page.dart';
import 'package:blokus/pages/splashscreen.dart';
import 'package:blokus/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  usePathUrlStrategy();

  await Supabase.initialize(
    url: 'https://igtfbjzlpverlfzsavno.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlndGZianpscHZlcmxmenNhdm5vIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODE1MzI1OTAsImV4cCI6MTk5NzEwODU5MH0.F-TEWzGfwOFZaXMOoKDQphAsp1aDJmF-7edX-R34Ziw',
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
  });
  final PlayerAuthentication playerAuthentication = PlayerAuthentication();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlayerAuthentication>.value(
      value: playerAuthentication,
      child: MaterialApp.router(
        title: 'Blokus',
        routerConfig: _router,
      ),
    );
  }

  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: SplashScreen(
            waitForSplashScreen: playerAuthentication.waitForSplashScreen,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LogInPage(playerAuthentication: playerAuthentication),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => GameBoardPage(
          playerAuthentication: playerAuthentication,
        ),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      bool loaded = playerAuthentication.splashScreenLoaded;
      bool signedIn = playerAuthentication.isSignedIn;
      String matchedLocation = state.matchedLocation;
      bool signingIn = matchedLocation == '/login';
      bool loading = matchedLocation == '/';

      if (!loaded) return loading ? null : '/';

      if (!signedIn) return signingIn ? null : '/login';

      if (signedIn) return '/home';

      return '/';
    },
    refreshListenable: playerAuthentication,
    errorBuilder: (context, state) =>
        LogInPage(playerAuthentication: playerAuthentication),
  );
}
