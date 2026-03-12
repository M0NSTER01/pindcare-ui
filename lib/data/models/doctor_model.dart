class DoctorModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? dateOfBirth;
  final String gender;
  final String? profilePhoto;
  final String registrationNumber;
  final String specialization;
  final int yearsOfExperience;
  final String? hospitalName;
  final String? clinicAddress;
  final Map<String, String> workingHours; // {'monday': '9:00-17:00', ...}
  final double consultationFee;
  final bool isVerified;
  final String verificationStatus; // pending, verified, rejected
  final List<String> languages;
  final String? degreeCertPath;
  final String? registrationCertPath;
  final bool isOnline;
  final double rating;
  final int totalPatients;
  final int consultationsThisMonth;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoctorModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.dateOfBirth,
    required this.gender,
    this.profilePhoto,
    required this.registrationNumber,
    required this.specialization,
    this.yearsOfExperience = 0,
    this.hospitalName,
    this.clinicAddress,
    this.workingHours = const {},
    this.consultationFee = 200,
    this.isVerified = false,
    this.verificationStatus = 'pending',
    this.languages = const ['Hindi', 'English'],
    this.degreeCertPath,
    this.registrationCertPath,
    this.isOnline = false,
    this.rating = 4.5,
    this.totalPatients = 0,
    this.consultationsThisMonth = 0,
    this.syncStatus = 'synced',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get initials =>
      name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'profilePhoto': profilePhoto,
        'registrationNumber': registrationNumber,
        'specialization': specialization,
        'yearsOfExperience': yearsOfExperience,
        'hospitalName': hospitalName,
        'clinicAddress': clinicAddress,
        'workingHours': workingHours,
        'consultationFee': consultationFee,
        'isVerified': isVerified,
        'verificationStatus': verificationStatus,
        'languages': languages,
        'degreeCertPath': degreeCertPath,
        'registrationCertPath': registrationCertPath,
        'isOnline': isOnline,
        'rating': rating,
        'totalPatients': totalPatients,
        'consultationsThisMonth': consultationsThisMonth,
        'syncStatus': syncStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DoctorModel.fromMap(Map<String, dynamic> map) => DoctorModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'],
        dateOfBirth: map['dateOfBirth'],
        gender: map['gender'] ?? '',
        profilePhoto: map['profilePhoto'],
        registrationNumber: map['registrationNumber'] ?? '',
        specialization: map['specialization'] ?? '',
        yearsOfExperience: map['yearsOfExperience'] ?? 0,
        hospitalName: map['hospitalName'],
        clinicAddress: map['clinicAddress'],
        workingHours: Map<String, String>.from(map['workingHours'] ?? {}),
        consultationFee: (map['consultationFee'] ?? 200).toDouble(),
        isVerified: map['isVerified'] ?? false,
        verificationStatus: map['verificationStatus'] ?? 'pending',
        languages: List<String>.from(map['languages'] ?? ['Hindi', 'English']),
        degreeCertPath: map['degreeCertPath'],
        registrationCertPath: map['registrationCertPath'],
        isOnline: map['isOnline'] ?? false,
        rating: (map['rating'] ?? 4.5).toDouble(),
        totalPatients: map['totalPatients'] ?? 0,
        consultationsThisMonth: map['consultationsThisMonth'] ?? 0,
        syncStatus: map['syncStatus'] ?? 'synced',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );

  DoctorModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? dateOfBirth,
    String? gender,
    String? profilePhoto,
    String? registrationNumber,
    String? specialization,
    int? yearsOfExperience,
    String? hospitalName,
    String? clinicAddress,
    Map<String, String>? workingHours,
    double? consultationFee,
    bool? isVerified,
    String? verificationStatus,
    List<String>? languages,
    String? degreeCertPath,
    String? registrationCertPath,
    bool? isOnline,
    double? rating,
    int? totalPatients,
    int? consultationsThisMonth,
    String? syncStatus,
  }) {
    return DoctorModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      hospitalName: hospitalName ?? this.hospitalName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      workingHours: workingHours ?? this.workingHours,
      consultationFee: consultationFee ?? this.consultationFee,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      languages: languages ?? this.languages,
      degreeCertPath: degreeCertPath ?? this.degreeCertPath,
      registrationCertPath: registrationCertPath ?? this.registrationCertPath,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      totalPatients: totalPatients ?? this.totalPatients,
      consultationsThisMonth: consultationsThisMonth ?? this.consultationsThisMonth,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
