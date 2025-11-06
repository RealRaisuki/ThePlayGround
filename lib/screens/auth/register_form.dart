
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback toggleForm;
  final AuthService authService;

  const RegisterForm({
    super.key,
    required this.toggleForm,
    required this.authService,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await widget.authService.registerWithEmail(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Registration successful! Please check your email for verification.'),
              backgroundColor: Colors.green,
            ),
          );
          widget.toggleForm();
        }
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'This email address is already in use.';
            break;
          case 'weak-password':
            message = 'The password provided is too weak.';
            break;
          case 'invalid-email':
            message = 'The email address is not valid.';
            break;
          default:
            message = 'An unknown error occurred. Please try again.';
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

  void _clearError() {
    setState(() {
        _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text('Create Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
            validator: (value) =>
                value!.isEmpty ? 'Please enter an email' : null,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
                labelText: 'Password', border: OutlineInputBorder()),
            obscureText: true,
            validator: (value) => value!.length < 6
                ? 'Password must be at least 6 characters'
                : null,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(
                labelText: 'Confirm Password', border: OutlineInputBorder()),
            obscureText: true,
            validator: (value) =>
                value != _passwordController.text ? 'Passwords do not match' : null,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  child: const Text('Register'),
                ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.toggleForm,
            child: const Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }
}
