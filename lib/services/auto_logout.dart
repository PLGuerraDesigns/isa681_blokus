import 'dart:async';

import 'package:blokus/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

class AutoLogout {
  final Duration timeout;
  final BuildContext context;
  final Function signOutCallback;

  AutoLogout({
    required this.timeout,
    required this.context,
    required this.signOutCallback,
  });

  late Timer _signOutTimer;
  late Timer _warningTimer;
  bool started = false;

  void _startTimer() {
    if (started) {
      _signOutTimer.cancel();
      _warningTimer.cancel();
    }
    _signOutTimer = Timer(timeout, () {
      signOutCallback();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar()
          .floatingMessage(context,
              'Your session has expired due to inactivity.', Colors.red[700]!));
    });
    _warningTimer = Timer(Duration(minutes: timeout.inMinutes ~/ 2), () {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar().floatingMessage(
          context,
          'Your session is about to expire due to inactivity. ${timeout.inMinutes ~/ 2} minutes remaining.',
          Colors.red[700]!));
    });
    started = true;
  }

  void resetTimer() {
    _startTimer();
  }

  void cancelTimer() {
    _signOutTimer.cancel();
    _warningTimer.cancel();
  }
}
