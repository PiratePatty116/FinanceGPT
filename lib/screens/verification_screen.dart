// screens/verification_screen.dart
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'home_screen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isEmailSent = true;
  bool _isLoading = false;
  bool _isVerifying = false;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    // Start timer to periodically check email verification
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkVerificationStatus(silent: true);
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      setState(() {
        _isEmailSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send verification email')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkVerificationStatus({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isVerifying = true;
      });
    }
    
    try {
      // Force a full reload of the user data from Firebase
      await FirebaseAuth.instance.currentUser!.reload();
      
      // Get the refreshed user object
      final user = FirebaseAuth.instance.currentUser;
      final isVerified = user != null && user.emailVerified;
      
      if (isVerified && mounted) {
        // If verified and we're explicitly checking (not silent check),
        // show a success message
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified successfully!')),
          );
        }
        
        // The stream in AuthWrapper will handle navigation
        // but we can force a navigation here as well
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not verified yet')),
        );
      }
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification check failed: ${e.toString()}')),
        );
      }
    } finally {
      if (!silent && mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We\'ve sent a verification email to:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'your email address',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Please check your inbox and click the verification link to complete your registration.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isVerifying ? null : () => _checkVerificationStatus(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('I\'ve Verified My Email'),
              ),
              const SizedBox(height: 16),
              if (!_isEmailSent)
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ) 
                      : const Text('Resend Verification Email'),
                )
              else
                TextButton(
                  onPressed: _isLoading ? null : _sendVerificationEmail,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ) 
                      : const Text('Resend Verification Email'),
                ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Cancel and Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}