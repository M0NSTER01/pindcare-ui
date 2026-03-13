/// Health record model matching the backend `/records/patient/:id` response.
class HealthRecordModel {
  final String id;
  final String doctorName;
  final String diagnosisSummary;
  final DateTime date;
  final String? pdfUrl;       // relative path e.g. /uploads/records/file.pdf
  final bool isEncrypted;
  final String? notes;
  final List<String> medications;

  HealthRecordModel({
    required this.id,
    required this.doctorName,
    required this.diagnosisSummary,
    required this.date,
    this.pdfUrl,
    this.isEncrypted = false,
    this.notes,
    this.medications = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'doctorName': doctorName,
    'diagnosisSummary': diagnosisSummary,
    'date': date.toIso8601String(),
    'pdfUrl': pdfUrl,
    'isEncrypted': isEncrypted,
    'notes': notes,
    'medications': medications,
  };

  factory HealthRecordModel.fromMap(Map<String, dynamic> map) =>
      HealthRecordModel(
        id: map['id'] ?? map['record_id'] ?? '',
        doctorName: map['doctorName'] ?? map['doctor_name'] ?? '',
        diagnosisSummary: map['diagnosisSummary'] ??
            map['diagnosis_summary'] ??
            map['diagnosis'] ??
            '',
        date: DateTime.tryParse(
                map['date'] ?? map['created_at'] ?? '') ??
            DateTime.now(),
        pdfUrl: map['pdfUrl'] ?? map['pdf_url'],
        isEncrypted: map['isEncrypted'] ?? map['is_encrypted'] ?? false,
        notes: map['notes'],
        medications: List<String>.from(map['medications'] ?? []),
      );
}
