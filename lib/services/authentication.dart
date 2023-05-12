import 'dart:async';

import 'package:blokus/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerAuthentication extends ChangeNotifier {
  SupabaseClient supabase = Supabase.instance.client;

  late final StreamSubscription<AuthState> authSubscription;
  User? user;

  PlayerAuthentication() {
    authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      user = session?.user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }

  bool _splashScreenLoaded = false;

  get splashScreenLoaded => _splashScreenLoaded;

  bool get isSignedIn => user != null;

  String get playerEmail => user == null ? '' : user!.email!;

  String get playerUID => user == null ? '' : user!.id;

  Future<void> waitForSplashScreen() async {
    if (!splashScreenLoaded) {
      await Future.delayed(const Duration(seconds: 3));
      _splashScreenLoaded = true;
      notifyListeners();
    }
  }

  bool _verifyEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(email);
  }

  Future<void> requestMagicLink(
      BuildContext context, TextEditingController emailController) async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar()
          .floatingMessage(context, 'Enter you email address to get started.',
              Colors.orange[700]!));

      return;
    }

    String emailAddress = emailController.text.substring(
        0, emailController.text.length > 30 ? 30 : emailController.text.length);

    if (!_verifyEmail(emailAddress)) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar()
          .floatingMessage(context, 'Invalid Email Format', Colors.red[700]!));
      return;
    }
    if (emailAddress.contains('gmu')) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar().floatingMessage(
          context,
          'This email provider does not support magic sign on. Please provide a different email address.',
          Colors.red[700]!));
      return;
    }
    try {
      await supabase.auth.signInWithOtp(
        email: emailAddress,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar()
            .floatingMessage(
                context,
                'Check your email for the instant sign in link!',
                Colors.blue[700]!));
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar()
          .floatingMessage(context, error.message, Colors.red[700]!));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar()
          .floatingMessage(
              context,
              'An unexpected error occurred. Please try again.',
              Colors.red[700]!));
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
