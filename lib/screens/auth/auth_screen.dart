
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLoginForm = true;

  void _toggleForm() {
    setState(() {
      _showLoginForm = !_showLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/AltTaskLogo.png',
                height: 190,
              ),
              const SizedBox(height: 48),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _showLoginForm
                    ? LoginForm(toggleForm: _toggleForm, authService: authService)
                    : RegisterForm(
                        toggleForm: _toggleForm, authService: authService),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
