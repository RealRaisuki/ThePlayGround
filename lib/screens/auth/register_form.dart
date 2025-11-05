
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'social_sign_in_button.dart';

class RegisterForm extends StatelessWidget {
  final VoidCallback toggleForm;
  final AuthService authService;

  const RegisterForm(
      {super.key, required this.toggleForm, required this.authService});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            authService.registerWithEmail(
                emailController.text, passwordController.text);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          child: const Text('Register'),
        ),
        const SizedBox(height: 16),
        SocialSignInButton(
          onPressed: () => authService.signInWithGoogle(),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: toggleForm,
          child: const Text('Already have an account? Login'),
        ),
      ],
    );
  }
}
