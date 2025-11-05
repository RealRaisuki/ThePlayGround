
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'forgot_password_dialog.dart';
import 'social_sign_in_button.dart';

class LoginForm extends StatelessWidget {
  final VoidCallback toggleForm;
  final AuthService authService;

  const LoginForm({super.key, required this.toggleForm, required this.authService});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Welcome Back!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
            authService.signInWithEmail(emailController.text, passwordController.text);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          child: const Text('Login'),
        ),
        const SizedBox(height: 16),
        SocialSignInButton(
          onPressed: () => authService.signInWithGoogle(),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: toggleForm,
          child: const Text("Don't have an account? Register"),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ForgotPasswordDialog(authService: authService),
            );
          },
          child: const Text('Forgot Password?'),
        ),
      ],
    );
  }
}
