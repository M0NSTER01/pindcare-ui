class PrescriptionModel {
  final String id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String duration;
  final String doctorName;
  final DateTime prescribedDate;
  final String? notes;
  final String syncStatus;

  PrescriptionModel({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.doctorName,
    required this.prescribedDate,
    this.notes,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'medicineName': medicineName,
    'dosage': dosage,
    'frequency': frequency,
    'duration': duration,
    'doctorName': doctorName,
    'prescribedDate': prescribedDate.toIso8601String(),
    'notes': notes,
    'syncStatus': syncStatus,
  };

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) => PrescriptionModel(
    id: map['id'] ?? '',
    medicineName: map['medicineName'] ?? '',
    dosage: map['dosage'] ?? '',
    frequency: map['frequency'] ?? '',
    duration: map['duration'] ?? '',
    doctorName: map['doctorName'] ?? '',
    prescribedDate: DateTime.tryParse(map['prescribedDate'] ?? '') ?? DateTime.now(),
    notes: map['notes'],
    syncStatus: map['syncStatus'] ?? 'synced',
  );
}
