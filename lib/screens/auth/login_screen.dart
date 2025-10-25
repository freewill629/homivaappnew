import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/homiva_logo.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final auth = context.read<AuthService>();
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await auth.signIn(email: _emailController.text.trim(), password: _passwordController.text.trim());
      } else {
        await auth.signUp(email: _emailController.text.trim(), password: _passwordController.text.trim());
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1121), Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: GlassContainer(
                  padding: const EdgeInsets.fromLTRB(32, 36, 32, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const HomivaLogo(size: 96),
                              const SizedBox(height: 16),
                              Text(
                                'Homiva',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _isLogin ? 'Sign in to continue' : 'Create your control hub',
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your smart tanks anywhere, anytime.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your password';
                            }
                            if (value.length < 6) {
                              return 'Use at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: _isLogin ? 'Sign In' : 'Sign Up',
                            onPressed: _submit,
                            loading: _loading,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(() {
                                      _isLogin = !_isLogin;
                                    }),
                            child: Text(
                              _isLogin ? 'Need an account? Sign up' : 'Already have an account? Sign in',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'By continuing you accept the Homiva Terms of Service.',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

