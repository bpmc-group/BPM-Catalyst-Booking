import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';

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

  void _init() {
    // Listen to Firebase auth state changes
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser != null) {
        // ⚠️ TEMPORARY LIMITATION: Role defaults to patient on re-login
        // TODO: Load user profile from Firestore with role information
        // This will be fixed when we implement Firestore integration in Week 2
        final user = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          role:
              UserRole.patient, // Will be properly loaded from Firestore later
          createdAt: DateTime.now(),
        );
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(user: null, isLoading: false);
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User will be set through the auth state listener
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
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // TODO: Create user document in Firestore with role information
        // For now, create local user object
        final user = User(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
        );

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
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    print('🔍 AuthProvider: Starting sign out...');
    print(
      '🔍 AuthProvider: Current user before sign out: ${state.user?.name} (${state.user?.role})',
    );

    state = state.copyWith(isLoading: true);

    try {
      print('🔍 AuthProvider: Calling Firebase signOut...');
      await _firebaseAuth.signOut();
      print('🔍 AuthProvider: Firebase signOut completed');
      state = state.copyWith(user: null, isLoading: false);
      print('🔍 AuthProvider: State updated - user should be null');
    } catch (e) {
      print('🔍 AuthProvider: Sign out failed with error: $e');
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
