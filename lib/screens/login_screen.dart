// screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _errorMessage = '';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Check passwords match when registering
      if (!_isLogin && _password != _confirmPassword) {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
        return;
      }
      
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        if (_isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message ?? 'An error occurred';
        });
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  // Title
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Sign in to continue' : 'Register to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Email Field
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!.trim(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFormField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (!_isLogin && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      _password = value; // Update password for immediate validation
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                    onChanged: (value) => _password = value,
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field (Only for Registration)
                  if (!_isLogin) ...[
                    TextFormField(
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _password) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onSaved: (value) => _confirmPassword = value!,
                      onChanged: (value) => _confirmPassword = value,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isLogin ? 'Sign In' : 'Create Account'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Switch between login and register
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = '';
                        _password = '';
                        _confirmPassword = '';
                      });
                      _formKey.currentState?.reset();
                    },
                    child: Text(
                      _isLogin
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Sign In',
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