  final String id;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorInitials;
  final double doctorRating;
  final List<String> doctorLanguages;
  final DateTime dateTime;
  final String type; // video, audio, chat
  final String status; // upcoming, completed, cancelled, pending, active
  final String? symptoms;
  final String? notes;
  final bool isOnline;
  final String syncStatus;
  // Backend fields
  final String? scanId;    // AI triage scan linked to this consultation
  final String? doctorId;  // backend doctor UUID
  final String? patientId; // backend patient UUID

  ConsultationModel({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorInitials,
    this.doctorRating = 4.5,
    this.doctorLanguages = const ['Hindi', 'English'],
    required this.dateTime,
    this.type = 'video',
    this.status = 'upcoming',
    this.symptoms,
    this.notes,
    this.isOnline = true,
    this.syncStatus = 'synced',
    this.scanId,
    this.doctorId,
    this.patientId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'doctorName': doctorName,
    'doctorSpecialization': doctorSpecialization,
    'doctorInitials': doctorInitials,
    'doctorRating': doctorRating,
    'doctorLanguages': doctorLanguages,
    'dateTime': dateTime.toIso8601String(),
    'type': type,
    'status': status,
    'symptoms': symptoms,
    'notes': notes,
    'isOnline': isOnline,
    'syncStatus': syncStatus,
    'scanId': scanId,
    'doctorId': doctorId,
    'patientId': patientId,
  };

  factory ConsultationModel.fromMap(Map<String, dynamic> map) => ConsultationModel(
    id: map['id'] ?? map['consultation_id'] ?? '',
    doctorName: map['doctorName'] ?? map['doctor_name'] ?? '',
    doctorSpecialization: map['doctorSpecialization'] ?? map['specialization'] ?? '',
    doctorInitials: map['doctorInitials'] ?? '',
    doctorRating: (map['doctorRating'] ?? map['rating'] ?? 4.5).toDouble(),
    doctorLanguages: List<String>.from(map['doctorLanguages'] ?? ['Hindi', 'English']),
    dateTime: DateTime.tryParse(map['dateTime'] ?? map['created_at'] ?? '') ?? DateTime.now(),
    type: map['type'] ?? 'video',
    status: map['status'] ?? 'upcoming',
    symptoms: map['symptoms'],
    notes: map['notes'],
    isOnline: map['isOnline'] ?? true,
    syncStatus: map['syncStatus'] ?? 'synced',
    scanId: map['scanId'] ?? map['scan_id'],
    doctorId: map['doctorId'] ?? map['doctor_id'],
    patientId: map['patientId'] ?? map['patient_id'],
  );
}
