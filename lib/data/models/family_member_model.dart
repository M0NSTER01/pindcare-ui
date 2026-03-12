class FamilyMemberModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String relation; // spouse, child, parent, sibling, other, self
  final String? bloodGroup;
  final List<String> chronicConditions;
  final String? allergies;
  final String? profilePhoto;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyMemberModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.relation,
    this.bloodGroup,
    this.chronicConditions = const [],
    this.allergies,
    this.profilePhoto,
    this.syncStatus = 'synced',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get initials =>
      name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();

  bool get isPrimary => relation == 'self';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'age': age,
        'gender': gender,
        'relation': relation,
        'bloodGroup': bloodGroup,
        'chronicConditions': chronicConditions,
        'allergies': allergies,
        'profilePhoto': profilePhoto,
        'syncStatus': syncStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory FamilyMemberModel.fromMap(Map<String, dynamic> map) => FamilyMemberModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        age: map['age'] ?? 0,
        gender: map['gender'] ?? '',
        relation: map['relation'] ?? 'other',
        bloodGroup: map['bloodGroup'],
        chronicConditions: List<String>.from(map['chronicConditions'] ?? []),
        allergies: map['allergies'],
        profilePhoto: map['profilePhoto'],
        syncStatus: map['syncStatus'] ?? 'synced',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );

  FamilyMemberModel copyWith({
    String? name,
    int? age,
    String? gender,
    String? relation,
    String? bloodGroup,
    List<String>? chronicConditions,
    String? allergies,
    String? profilePhoto,
    String? syncStatus,
  }) {
    return FamilyMemberModel(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      relation: relation ?? this.relation,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      allergies: allergies ?? this.allergies,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
