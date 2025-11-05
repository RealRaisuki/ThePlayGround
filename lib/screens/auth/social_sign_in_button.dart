
import 'package:flutter/material.dart';

class SocialSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SocialSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Image.asset('assets/images/google_logo.png', height: 24.0), // Ensure you have a Google logo asset
      label: const Text('Sign in with Google'),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
