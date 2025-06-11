import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _doctors => _firestore.collection('doctors');
  CollectionReference get _appointments =>
      _firestore.collection('appointments');

  /// Create or update user profile in Firestore
  Future<void> createUserProfile(User user) async {
    try {
      await _users.doc(user.id).set({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'role': user.role.toString().split('.').last, // Convert enum to string
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ DatabaseService: User profile created/updated for ${user.name}');
    } catch (e) {
      print('❌ DatabaseService: Failed to create user profile: $e');
      rethrow;
    }
  }

  /// Get user profile from Firestore
  Future<User?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _users.doc(userId).get();

      if (!doc.exists) {
        print('⚠️ DatabaseService: User profile not found for ID: $userId');
        return null;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Convert string back to enum
      UserRole role =
          data['role'] == 'doctor' ? UserRole.doctor : UserRole.patient;

      User user = User(
        id: data['id'],
        email: data['email'],
        name: data['name'],
        role: role,
        createdAt: DateTime.parse(data['createdAt']),
      );

      print(
        '✅ DatabaseService: User profile retrieved for ${user.name} (${user.role})',
      );
      return user;
    } catch (e) {
      print('❌ DatabaseService: Failed to get user profile: $e');
      rethrow;
    }
  }

  /// Create or update doctor profile with professional information
  Future<void> createDoctorProfile({
    required String userId,
    required String specialization,
    required String licenseNumber,
    required int experienceYears,
    required String education,
    required String bio,
    List<String> availableDays = const [],
    String? phoneNumber,
    String? clinicAddress,
  }) async {
    try {
      await _doctors.doc(userId).set({
        'userId': userId,
        'specialization': specialization,
        'licenseNumber': licenseNumber,
        'experienceYears': experienceYears,
        'education': education,
        'bio': bio,
        'availableDays': availableDays,
        'phoneNumber': phoneNumber,
        'clinicAddress': clinicAddress,
        'isVerified': false, // Initially unverified
        'rating': 0.0,
        'totalRatings': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ DatabaseService: Doctor profile created for user: $userId');
    } catch (e) {
      print('❌ DatabaseService: Failed to create doctor profile: $e');
      rethrow;
    }
  }

  /// Get doctor profile
  Future<Map<String, dynamic>?> getDoctorProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _doctors.doc(userId).get();

      if (!doc.exists) {
        print('⚠️ DatabaseService: Doctor profile not found for user: $userId');
        return null;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print('✅ DatabaseService: Doctor profile retrieved for user: $userId');
      return data;
    } catch (e) {
      print('❌ DatabaseService: Failed to get doctor profile: $e');
      rethrow;
    }
  }

  /// Get all doctors for patient view
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      QuerySnapshot querySnapshot =
          await _doctors
              .where('isVerified', isEqualTo: true) // Only verified doctors
              .orderBy('rating', descending: true)
              .get();

      List<Map<String, dynamic>> doctors = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> doctorData = doc.data() as Map<String, dynamic>;

        // Get user profile for doctor's basic info
        User? userProfile = await getUserProfile(doctorData['userId']);
        if (userProfile != null) {
          doctorData['name'] = userProfile.name;
          doctorData['email'] = userProfile.email;
        }

        doctors.add(doctorData);
      }

      print('✅ DatabaseService: Retrieved ${doctors.length} verified doctors');
      return doctors;
    } catch (e) {
      print('❌ DatabaseService: Failed to get doctors: $e');
      rethrow;
    }
  }

  /// Update doctor availability
  Future<void> updateDoctorAvailability(
    String userId,
    List<String> availableDays,
  ) async {
    try {
      await _doctors.doc(userId).update({
        'availableDays': availableDays,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ DatabaseService: Updated availability for doctor: $userId');
    } catch (e) {
      print('❌ DatabaseService: Failed to update doctor availability: $e');
      rethrow;
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String userId) async {
    try {
      DocumentSnapshot doc = await _users.doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('❌ DatabaseService: Failed to check if user exists: $e');
      return false;
    }
  }

  /// Delete user and associated data (for testing/cleanup)
  Future<void> deleteUser(String userId) async {
    try {
      // Delete from users collection
      await _users.doc(userId).delete();

      // Delete from doctors collection if exists
      DocumentSnapshot doctorDoc = await _doctors.doc(userId).get();
      if (doctorDoc.exists) {
        await _doctors.doc(userId).delete();
      }

      print('✅ DatabaseService: User and associated data deleted for: $userId');
    } catch (e) {
      print('❌ DatabaseService: Failed to delete user: $e');
      rethrow;
    }
  }

  /// Listen to user profile changes (for real-time updates)
  Stream<User?> getUserProfileStream(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      UserRole role =
          data['role'] == 'doctor' ? UserRole.doctor : UserRole.patient;

      return User(
        id: data['id'],
        email: data['email'],
        name: data['name'],
        role: role,
        createdAt: DateTime.parse(data['createdAt']),
      );
    });
  }
}
