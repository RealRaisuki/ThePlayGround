
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'forgot_password_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback toggleForm;
  final AuthService authService;

  const LoginForm({super.key, required this.toggleForm, required this.authService});

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await widget.authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        // Navigation to the home screen will be handled by the StreamBuilder in main.dart
      } on FirebaseAuthException catch (e) {
        String message;
        // Simplified error mapping
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
            message = 'Invalid email or password.';
        } else {
            message = 'An error occurred. Please try again.';
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
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text('Welcome Back!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
            keyboardType: TextInputType.emailAddress,
             onChanged: (_) {
                setState(() {
                    _errorMessage = null;
                });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            obscureText: true,
            validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
             onChanged: (_) {
                setState(() {
                    _errorMessage = null;
                });
            },
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text('Login'),
                ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.toggleForm,
            child: const Text("Don't have an account? Register"),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ForgotPasswordDialog(authService: widget.authService),
              );
            },
            child: const Text('Forgot Password?'),
          ),
        ],
      ),
    );
  }
}
