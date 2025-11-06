
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordDialog extends StatefulWidget {
  final AuthService authService;

  const ForgotPasswordDialog({super.key, required this.authService});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _sendResetEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter an email";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await widget.authService.sendPasswordResetEmail(_emailController.text);
      setState(() {
        _successMessage = 'Password reset email sent! Check your inbox.';
      });
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else {
        message = "An error occurred. Please try again";
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          if (_successMessage != null)
             Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
                setState(() {
                    _errorMessage = null;
                    _successMessage = null;
                });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _sendResetEmail,
                child: const Text('Send'),
              ),
      ],
    );
  }
}
