import 'package:blokus/services/authentication.dart';
import 'package:blokus/widgets/gmu_blokus_background.dart';
import 'package:flutter/material.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key, required this.playerAuthentication});
  final PlayerAuthentication playerAuthentication;

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GMUBlokusBackground(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            constraints: const BoxConstraints(
              maxHeight: 350,
              maxWidth: 500,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'BLOKUS',
                    style: TextStyle(
                        fontFamily: 'LemonMilk',
                        fontSize: 70,
                        color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Log In',
                    style: TextStyle(
                      fontFamily: 'LemonMilk',
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    maxLength: 30,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  MaterialButton(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    disabledColor: Colors.blue.withOpacity(0.25),
                    onPressed: () => widget.playerAuthentication
                        .requestMagicLink(context, emailController),
                    child: const Text(
                      'REQUEST MAGIC LINK SIGN ON',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
