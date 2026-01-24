import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    Future.microtask(() {
      ref.listenManual(authProvider, (previous, next) {
        // Navigate to home when authentication succeeds
        if (next.isAuthenticated && mounted) {
          Navigator.pushReplacementNamed(context, "/home");
        }

        // Show error if authentication fails
        if (next.error != null && mounted) {
          setState(() {
            _errorMessage = next.error;
            _isLoading = false;
          });
        }
      });
    });
  }

  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      developer.log("Sign up successful");
    } catch (e) {
      developer.log("Sign up error: $e");
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      developer.log("Google sign in initiated");
    } catch (e) {
      developer.log("Google sign in error: $e");

      if (mounted) {
        setState(() {
          if (e.toString().contains('canceled') ||
              e.toString().contains('sign_in_canceled')) {
            _errorMessage = null;
            _isLoading = false;
          } else {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
          }
        });
      }
    } finally {
      if (mounted && _errorMessage != null) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthLoading = _isLoading || authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pinterest-style image grid
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        // Top left image
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 150,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        // Center image
                        Positioned(
                          top: 20,
                          left: 80,
                          right: 80,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        // Bottom left image
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 150,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        // Top right image
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 150,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        // Bottom right image
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 150,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Create a life\nyou love',
                    style: GoogleFonts.roboto(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Create a password',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.transparent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please create a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Error Message
                  if (_errorMessage != null || authState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authState.error ?? _errorMessage!,
                        style: GoogleFonts.roboto(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Continue Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isAuthLoading ? null : _handleEmailSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE60023),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: isAuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Continue',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // OR divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey[700], thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: GoogleFonts.roboto(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey[700], thickness: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign In Button
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: isAuthLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[700]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/500px-Google_%22G%22_logo.svg.png',
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to ',
                      style: GoogleFonts.roboto(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(
                          text: ' and acknowledge that you\'ve read our ',
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Toggle to Login
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.pushNamed(
                          '/login',
                          queryParameters: {
                            'email': _emailController.text.trim(),
                          },
                        );
                      },
                      child: Text(
                        'Already a member? Log in',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
