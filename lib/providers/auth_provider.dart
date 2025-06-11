import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/database_service.dart';

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  void _init() {
    // Listen to Firebase auth state changes
    _firebaseAuth.authStateChanges().listen((
      firebase_auth.User? firebaseUser,
    ) async {
      if (firebaseUser != null) {
        print(
          '🔍 AuthProvider: Firebase user authenticated: ${firebaseUser.email}',
        );

        try {
          // 🚀 WEEK 2 FIX: Load user profile from Firestore
          User? userProfile = await _databaseService.getUserProfile(
            firebaseUser.uid,
          );

          if (userProfile != null) {
            // User exists in Firestore - use the stored profile with correct role
            print(
              '✅ AuthProvider: User profile loaded from Firestore with role: ${userProfile.role}',
            );
            state = state.copyWith(user: userProfile, isLoading: false);
          } else {
            // New user - create a basic profile (role will be set during registration)
            print(
              '⚠️ AuthProvider: No Firestore profile found, creating basic user profile',
            );
            final user = User(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              name: firebaseUser.displayName ?? 'User',
              role: UserRole.patient, // Default role for fallback
              createdAt: DateTime.now(),
            );

            // Don't store to Firestore yet - this will be done during registration
            state = state.copyWith(user: user, isLoading: false);
          }
        } catch (e) {
          print('❌ AuthProvider: Error loading user profile: $e');
          // Fallback to basic user if Firestore fails
          final user = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'User',
            role: UserRole.patient,
            createdAt: DateTime.now(),
          );
          state = state.copyWith(user: user, isLoading: false);
        }
      } else {
        print('🔍 AuthProvider: User signed out');
        state = state.copyWith(user: null, isLoading: false);
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔍 AuthProvider: Attempting sign in for: $email');
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User will be set through the auth state listener with Firestore data
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
      rethrow;
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print(
        '🔍 AuthProvider: Creating user account for: $email with role: $role',
      );
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name in Firebase Auth
        await credential.user!.updateDisplayName(name);

        // 🚀 WEEK 2 ENHANCEMENT: Create user profile in Firestore
        final user = User(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
        );

        // Store user profile in Firestore
        await _databaseService.createUserProfile(user);
        print('✅ AuthProvider: User profile created in Firestore');

        state = state.copyWith(user: user, isLoading: false);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    } catch (e) {
      print('❌ AuthProvider: Registration error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
      rethrow;
    }
  }

  /// 🚀 WEEK 2 NEW METHOD: Create doctor profile with professional information
  Future<void> createDoctorProfile({
    required String specialization,
    required String licenseNumber,
    required int experienceYears,
    required String education,
    required String bio,
    String? phoneNumber,
    String? clinicAddress,
  }) async {
    if (state.user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      print(
        '🔍 AuthProvider: Creating doctor profile for: ${state.user!.name}',
      );
      await _databaseService.createDoctorProfile(
        userId: state.user!.id,
        specialization: specialization,
        licenseNumber: licenseNumber,
        experienceYears: experienceYears,
        education: education,
        bio: bio,
        phoneNumber: phoneNumber,
        clinicAddress: clinicAddress,
      );
      print('✅ AuthProvider: Doctor profile created successfully');
    } catch (e) {
      print('❌ AuthProvider: Failed to create doctor profile: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _firebaseAuth.signOut();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      print('❌ AuthProvider: Sign out failed with error: $e');
      state = state.copyWith(isLoading: false, error: 'Sign out failed.');
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user != null;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).user?.role;
});

final isDoctorProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user?.role == UserRole.doctor;
});

final isPatientProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user?.role == UserRole.patient;
});

// 🚀 WEEK 2 NEW PROVIDER: Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
