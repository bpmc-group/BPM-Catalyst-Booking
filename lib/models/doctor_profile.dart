class DoctorProfile {
  final String id;
  final String userId; // Reference to User
  final String licenseNumber;
  final String specialization;
  final String hospital;
  final int experience; // years
  final double consultationFee;
  final String bio;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final bool isActive;
  final List<String> qualifications;
  final List<String> languages;

  DoctorProfile({
    required this.id,
    required this.userId,
    required this.licenseNumber,
    required this.specialization,
    required this.hospital,
    required this.experience,
    required this.consultationFee,
    required this.bio,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.isActive = true,
    this.qualifications = const [],
    this.languages = const [],
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      licenseNumber: json['licenseNumber'] as String,
      specialization: json['specialization'] as String,
      hospital: json['hospital'] as String,
      experience: json['experience'] as int,
      consultationFee: (json['consultationFee'] as num).toDouble(),
      bio: json['bio'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      qualifications: List<String>.from(json['qualifications'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'licenseNumber': licenseNumber,
      'specialization': specialization,
      'hospital': hospital,
      'experience': experience,
      'consultationFee': consultationFee,
      'bio': bio,
      'rating': rating,
      'totalReviews': totalReviews,
      'isVerified': isVerified,
      'isActive': isActive,
      'qualifications': qualifications,
      'languages': languages,
    };
  }

  DoctorProfile copyWith({
    String? id,
    String? userId,
    String? licenseNumber,
    String? specialization,
    String? hospital,
    int? experience,
    double? consultationFee,
    String? bio,
    double? rating,
    int? totalReviews,
    bool? isVerified,
    bool? isActive,
    List<String>? qualifications,
    List<String>? languages,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialization: specialization ?? this.specialization,
      hospital: hospital ?? this.hospital,
      experience: experience ?? this.experience,
      consultationFee: consultationFee ?? this.consultationFee,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      qualifications: qualifications ?? this.qualifications,
      languages: languages ?? this.languages,
    );
  }
}
