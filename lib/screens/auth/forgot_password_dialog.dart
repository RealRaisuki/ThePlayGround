
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordDialog extends StatelessWidget {
  final AuthService authService;

  const ForgotPasswordDialog({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(
        controller: emailController,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            authService.sendPasswordResetEmail(emailController.text);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password reset email sent.')),
            );
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}
