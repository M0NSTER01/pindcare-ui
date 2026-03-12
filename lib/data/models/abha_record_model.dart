class AbhaRecordModel {
  final String id;
  final String type; // condition, medication, diagnostic, imaging
  final String abhaId;
  final String patientName;
  final DateTime date;
  final String facilityName;
  final String? doctorName;
  final String summary;
  final String? details;
  final Map<String, dynamic> fhirData; // raw FHIR R4 resource
  final String syncStatus;
  final DateTime fetchedAt;

  AbhaRecordModel({
    required this.id,
    required this.type,
    required this.abhaId,
    required this.patientName,
    required this.date,
    required this.facilityName,
    this.doctorName,
    required this.summary,
    this.details,
    this.fhirData = const {},
    this.syncStatus = 'synced',
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  String get typeLabel {
    switch (type) {
      case 'condition':
        return 'Diagnosis';
      case 'medication':
        return 'Prescription';
      case 'diagnostic':
        return 'Lab Report';
      case 'imaging':
        return 'Scan / Imaging';
      default:
        return 'Record';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'abhaId': abhaId,
        'patientName': patientName,
        'date': date.toIso8601String(),
        'facilityName': facilityName,
        'doctorName': doctorName,
        'summary': summary,
        'details': details,
        'fhirData': fhirData,
        'syncStatus': syncStatus,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory AbhaRecordModel.fromMap(Map<String, dynamic> map) => AbhaRecordModel(
        id: map['id'] ?? '',
        type: map['type'] ?? '',
        abhaId: map['abhaId'] ?? '',
        patientName: map['patientName'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        facilityName: map['facilityName'] ?? '',
        doctorName: map['doctorName'],
        summary: map['summary'] ?? '',
        details: map['details'],
        fhirData: Map<String, dynamic>.from(map['fhirData'] ?? {}),
        syncStatus: map['syncStatus'] ?? 'synced',
        fetchedAt: DateTime.tryParse(map['fetchedAt'] ?? '') ?? DateTime.now(),
      );
}
