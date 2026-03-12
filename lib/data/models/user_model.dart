class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? dateOfBirth;
  final String gender;
  final String role; // doctor, patient, asha
  final String? profilePhoto;
  final String? village;
  final String? district;
  final String? state;
  final String? bloodGroup;
  final String? emergencyContactName;
  final String? emergencyContact;
  final List<String> chronicConditions;
  final String? allergies;
  final String? ashaWorkerId;
  final double? lastBp;
  final double? lastTemperature;
  final double? lastWeight;
  final String syncStatus;
  final String? memberId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.dateOfBirth,
    required this.gender,
    required this.role,
    this.profilePhoto,
    this.village,
    this.district,
    this.state,
    this.bloodGroup,
    this.emergencyContactName,
    this.emergencyContact,
    this.chronicConditions = const [],
    this.allergies,
    this.ashaWorkerId,
    this.lastBp,
    this.lastTemperature,
    this.lastWeight,
    this.syncStatus = 'synced',
    this.memberId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'role': role,
        'profilePhoto': profilePhoto,
        'village': village,
        'district': district,
        'state': state,
        'bloodGroup': bloodGroup,
        'emergencyContactName': emergencyContactName,
        'emergencyContact': emergencyContact,
        'chronicConditions': chronicConditions,
        'allergies': allergies,
        'ashaWorkerId': ashaWorkerId,
        'lastBp': lastBp,
        'lastTemperature': lastTemperature,
        'lastWeight': lastWeight,
        'syncStatus': syncStatus,
        'memberId': memberId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'],
        dateOfBirth: map['dateOfBirth'],
        gender: map['gender'] ?? '',
        role: map['role'] ?? 'patient',
        profilePhoto: map['profilePhoto'],
        village: map['village'],
        district: map['district'],
        state: map['state'],
        bloodGroup: map['bloodGroup'],
        emergencyContactName: map['emergencyContactName'],
        emergencyContact: map['emergencyContact'],
        chronicConditions: List<String>.from(map['chronicConditions'] ?? []),
        allergies: map['allergies'],
        ashaWorkerId: map['ashaWorkerId'],
        lastBp: map['lastBp']?.toDouble(),
        lastTemperature: map['lastTemperature']?.toDouble(),
        lastWeight: map['lastWeight']?.toDouble(),
        syncStatus: map['syncStatus'] ?? 'synced',
        memberId: map['memberId'],
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? dateOfBirth,
    String? gender,
    String? role,
    String? profilePhoto,
    String? village,
    String? district,
    String? state,
    String? bloodGroup,
    String? emergencyContactName,
    String? emergencyContact,
    List<String>? chronicConditions,
    String? allergies,
    String? ashaWorkerId,
    double? lastBp,
    double? lastTemperature,
    double? lastWeight,
    String? syncStatus,
    String? memberId,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      allergies: allergies ?? this.allergies,
      ashaWorkerId: ashaWorkerId ?? this.ashaWorkerId,
      lastBp: lastBp ?? this.lastBp,
      lastTemperature: lastTemperature ?? this.lastTemperature,
      lastWeight: lastWeight ?? this.lastWeight,
      syncStatus: syncStatus ?? this.syncStatus,
      memberId: memberId ?? this.memberId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
