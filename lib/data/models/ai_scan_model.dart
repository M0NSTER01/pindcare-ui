class AiScanModel {
  final String id;
  final String imagePath;
  final String conditionName;
  final String conditionType; // wound, rash, infection, etc.
  final double confidence;
  final String severity; // mild, moderate, severe
  final String description;
  final List<String> firstAidSteps;
  final bool shouldSeeDoctor;
  final String doctorReasoning;
  final DateTime scannedAt;
  final String syncStatus;

  AiScanModel({
    required this.id,
    required this.imagePath,
    required this.conditionName,
    required this.conditionType,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.firstAidSteps,
    required this.shouldSeeDoctor,
    required this.doctorReasoning,
    DateTime? scannedAt,
    this.syncStatus = 'synced',
  }) : scannedAt = scannedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'imagePath': imagePath,
    'conditionName': conditionName,
    'conditionType': conditionType,
    'confidence': confidence,
    'severity': severity,
    'description': description,
    'firstAidSteps': firstAidSteps,
    'shouldSeeDoctor': shouldSeeDoctor,
    'doctorReasoning': doctorReasoning,
    'scannedAt': scannedAt.toIso8601String(),
    'syncStatus': syncStatus,
  };

  factory AiScanModel.fromMap(Map<String, dynamic> map) => AiScanModel(
    id: map['id'] ?? '',
    imagePath: map['imagePath'] ?? '',
    conditionName: map['conditionName'] ?? '',
    conditionType: map['conditionType'] ?? '',
    confidence: (map['confidence'] ?? 0.0).toDouble(),
    severity: map['severity'] ?? 'mild',
    description: map['description'] ?? '',
    firstAidSteps: List<String>.from(map['firstAidSteps'] ?? []),
    shouldSeeDoctor: map['shouldSeeDoctor'] ?? false,
    doctorReasoning: map['doctorReasoning'] ?? '',
    scannedAt: DateTime.tryParse(map['scannedAt'] ?? '') ?? DateTime.now(),
    syncStatus: map['syncStatus'] ?? 'synced',
  );
}
