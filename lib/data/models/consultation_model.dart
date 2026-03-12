class ConsultationModel {
  final String id;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorInitials;
  final double doctorRating;
  final List<String> doctorLanguages;
  final DateTime dateTime;
  final String type; // video, audio, chat
  final String status; // upcoming, completed, cancelled
  final String? symptoms;
  final String? notes;
  final bool isOnline;
  final String syncStatus;

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
  };

  factory ConsultationModel.fromMap(Map<String, dynamic> map) => ConsultationModel(
    id: map['id'] ?? '',
    doctorName: map['doctorName'] ?? '',
    doctorSpecialization: map['doctorSpecialization'] ?? '',
    doctorInitials: map['doctorInitials'] ?? '',
    doctorRating: (map['doctorRating'] ?? 4.5).toDouble(),
    doctorLanguages: List<String>.from(map['doctorLanguages'] ?? ['Hindi', 'English']),
    dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
    type: map['type'] ?? 'video',
    status: map['status'] ?? 'upcoming',
    symptoms: map['symptoms'],
    notes: map['notes'],
    isOnline: map['isOnline'] ?? true,
    syncStatus: map['syncStatus'] ?? 'synced',
  );
}
