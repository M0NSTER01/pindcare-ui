class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final String? patientVillage;
  final String? patientPhoto;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime dateTime;
  final int durationMinutes;
  final String type; // video, audio, chat
  final String status; // upcoming, in_progress, completed, cancelled
  final String? symptoms;
  final String? notes;
  final String? memberId;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    this.patientVillage,
    this.patientPhoto,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.dateTime,
    this.durationMinutes = 15,
    this.type = 'video',
    this.status = 'upcoming',
    this.symptoms,
    this.notes,
    this.memberId,
    this.syncStatus = 'synced',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        'patientAge': patientAge,
        'patientVillage': patientVillage,
        'patientPhoto': patientPhoto,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorSpecialization': doctorSpecialization,
        'dateTime': dateTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'type': type,
        'status': status,
        'symptoms': symptoms,
        'notes': notes,
        'memberId': memberId,
        'syncStatus': syncStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AppointmentModel.fromMap(Map<String, dynamic> map) => AppointmentModel(
        id: map['id'] ?? '',
        patientId: map['patientId'] ?? '',
        patientName: map['patientName'] ?? '',
        patientAge: map['patientAge'] ?? 0,
        patientVillage: map['patientVillage'],
        patientPhoto: map['patientPhoto'],
        doctorId: map['doctorId'] ?? '',
        doctorName: map['doctorName'] ?? '',
        doctorSpecialization: map['doctorSpecialization'] ?? '',
        dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
        durationMinutes: map['durationMinutes'] ?? 15,
        type: map['type'] ?? 'video',
        status: map['status'] ?? 'upcoming',
        symptoms: map['symptoms'],
        notes: map['notes'],
        memberId: map['memberId'],
        syncStatus: map['syncStatus'] ?? 'synced',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );

  AppointmentModel copyWith({
    String? status,
    String? notes,
    String? syncStatus,
  }) {
    return AppointmentModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientAge: patientAge,
      patientVillage: patientVillage,
      patientPhoto: patientPhoto,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      dateTime: dateTime,
      durationMinutes: durationMinutes,
      type: type,
      status: status ?? this.status,
      symptoms: symptoms,
      notes: notes ?? this.notes,
      memberId: memberId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
