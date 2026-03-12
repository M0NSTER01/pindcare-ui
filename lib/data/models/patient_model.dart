class PatientModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String village;
  final String district;
  final String state;
  final String bloodGroup;
  final String emergencyContact;
  final String emergencyContactName;
  final String? avatarUrl;
  final double? lastBp;
  final double? lastTemperature;
  final double? lastWeight;
  final String syncStatus;
  final DateTime createdAt;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.village,
    required this.district,
    required this.state,
    required this.bloodGroup,
    required this.emergencyContact,
    required this.emergencyContactName,
    this.avatarUrl,
    this.lastBp,
    this.lastTemperature,
    this.lastWeight,
    this.syncStatus = 'synced',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'village': village,
    'district': district,
    'state': state,
    'bloodGroup': bloodGroup,
    'emergencyContact': emergencyContact,
    'emergencyContactName': emergencyContactName,
    'avatarUrl': avatarUrl,
    'lastBp': lastBp,
    'lastTemperature': lastTemperature,
    'lastWeight': lastWeight,
    'syncStatus': syncStatus,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PatientModel.fromMap(Map<String, dynamic> map) => PatientModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    age: map['age'] ?? 0,
    gender: map['gender'] ?? '',
    village: map['village'] ?? '',
    district: map['district'] ?? '',
    state: map['state'] ?? '',
    bloodGroup: map['bloodGroup'] ?? '',
    emergencyContact: map['emergencyContact'] ?? '',
    emergencyContactName: map['emergencyContactName'] ?? '',
    avatarUrl: map['avatarUrl'],
    lastBp: map['lastBp']?.toDouble(),
    lastTemperature: map['lastTemperature']?.toDouble(),
    lastWeight: map['lastWeight']?.toDouble(),
    syncStatus: map['syncStatus'] ?? 'synced',
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}
