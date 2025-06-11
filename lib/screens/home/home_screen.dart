import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _logout(WidgetRef ref) async {
    print('🔍 Logout button pressed');
    print('🔍 Current user: ${ref.read(currentUserProvider)?.name}');
    print('🔍 Is doctor: ${ref.read(isDoctorProvider)}');

    try {
      print('🔍 Calling sign out...');
      await ref.read(authProvider.notifier).signOut();
      print('🔍 Sign out completed successfully');
      // AuthWrapper will handle navigation automatically
    } catch (e) {
      print('🔍 Sign out error: $e');
      // Error handling will be done by AuthWrapper
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDoctor = ref.watch(isDoctorProvider);

    // Show loading if user is null (shouldn't happen due to AuthWrapper)
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header with role-specific greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDoctor
                              ? 'Welcome back,\nDr. ${user.name}!'
                              : 'Welcome back,\n${user.name}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A87),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDoctor
                                        ? const Color(0xFF00BCD4)
                                        : const Color(0xFF2196F3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isDoctor ? 'Doctor' : 'Patient',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => _logout(ref),
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFF2D5A87),
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Role-specific dashboard preview
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color:
                                isDoctor
                                    ? const Color(0xFFE0F7FA)
                                    : const Color(0xFFE8F4F8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDoctor
                                ? Icons.medical_services
                                : Icons.calendar_today,
                            color:
                                isDoctor
                                    ? const Color(0xFF00BCD4)
                                    : const Color(0xFF4A90A4),
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          isDoctor
                              ? 'Doctor Dashboard Coming Soon!'
                              : 'Patient Dashboard Coming Soon!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A87),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          isDoctor
                              ? 'Manage your appointments, set availability,\nand connect with patients.'
                              : 'Book appointments with qualified doctors,\nview your medical history, and more.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Role-specific action buttons
                        if (isDoctor) ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Availability management coming soon!',
                                  ),
                                  backgroundColor: Color(0xFF00BCD4),
                                ),
                              );
                            },
                            icon: const Icon(Icons.schedule),
                            label: const Text('Set Availability'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BCD4),
                              minimumSize: const Size(200, 48),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Patient management coming soon!',
                                  ),
                                  backgroundColor: Color(0xFF00BCD4),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people),
                            label: const Text('View Patients'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF00BCD4),
                              side: const BorderSide(color: Color(0xFF00BCD4)),
                              minimumSize: const Size(200, 48),
                            ),
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Booking feature coming soon!'),
                                  backgroundColor: Color(0xFF4A90A4),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Book Appointment'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 48),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Doctor list coming soon!'),
                                  backgroundColor: Color(0xFF4A90A4),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('Find Doctors'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4A90A4),
                              side: const BorderSide(color: Color(0xFF4A90A4)),
                              minimumSize: const Size(200, 48),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
