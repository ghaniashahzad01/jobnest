
import 'package:flutter/material.dart';
import '../widgets/auth_header.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role});

  final String role;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmployer = widget.role == 'employer';

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: 'Welcome back.',
                subtitle: isEmployer
                    ? 'Sign in to manage your company and applicants.'
                    : 'Sign in to continue your career journey.',
              ),
              const SizedBox(height: 36),
              const Text('Email address'),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 22),
              const Text('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => obscurePassword = !obscurePassword,
                    ),
                    icon: Icon(obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Authentication will be connected in the next step.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Log In'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SignupScreen(role: widget.role),
                    ),
                  ),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
