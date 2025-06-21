import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import 'register_screen.dart';
import 'doctor_registration_screen.dart';

class UserTypeSelectionScreen extends ConsumerWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // App Logo or Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'BPM Catalyst Booking',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Choose your account type to get started',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Patient Card
              UserTypeCard(
                title: "I'm a Patient",
                subtitle: "Book appointments with qualified doctors",
                icon: Icons.person,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              const RegisterScreen(userType: UserRole.patient),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Doctor Card
              UserTypeCard(
                title: "I'm a Doctor",
                subtitle: "Manage your practice and appointments",
                icon: Icons.medical_services,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorRegistrationScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const UserTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
