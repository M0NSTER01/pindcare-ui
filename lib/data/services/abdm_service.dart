import '../models/abha_record_model.dart';

class ABDMService {
  ABDMService._();
  static final ABDMService instance = ABDMService._();

  /// Fetch patient records from ABHA. Currently returns mock FHIR data.
  Future<ABDMFetchResult> fetchPatientRecords(String abhaId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    return ABDMFetchResult(
      patientName: 'Sukhwinder Kaur',
      abhaId: abhaId,
      dateOfBirth: '1985-03-15',
      gender: 'Female',
      bloodGroup: 'A+',
      address: 'Village Bhurthala, Nabha, Patiala, Punjab',
      records: _getMockRecords(abhaId),
    );
  }

  /// Simulate sending consent request
  Future<bool> sendConsentRequest(String abhaId, String phoneHint) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  /// Simulate checking consent status
  Future<bool> checkConsentStatus(String requestId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  List<AbhaRecordModel> _getMockRecords(String abhaId) {
    return [
      AbhaRecordModel(
        id: 'ABHA-REC-001',
        type: 'condition',
        abhaId: abhaId,
        patientName: 'Sukhwinder Kaur',
        date: DateTime(2024, 11, 15),
        facilityName: 'Rajindra Hospital, Patiala',
        doctorName: 'Dr. Manpreet Singh',
        summary: 'Type 2 Diabetes Mellitus — HbA1c 7.2%',
        details: 'Patient diagnosed with T2DM. Started on Metformin 500mg BD. Advised dietary modifications and regular exercise. Follow-up in 3 months.',
        fhirData: {
          'resourceType': 'Condition',
          'id': 'cond-001',
          'clinicalStatus': {'coding': [{'code': 'active'}]},
          'verificationStatus': {'coding': [{'code': 'confirmed'}]},
          'code': {
            'coding': [
              {'system': 'http://snomed.info/sct', 'code': '44054006', 'display': 'Type 2 diabetes mellitus'}
            ]
          },
          'subject': {'reference': 'Patient/$abhaId'},
          'onsetDateTime': '2024-11-15',
        },
      ),
      AbhaRecordModel(
        id: 'ABHA-REC-002',
        type: 'medication',
        abhaId: abhaId,
        patientName: 'Sukhwinder Kaur',
        date: DateTime(2024, 11, 15),
        facilityName: 'Rajindra Hospital, Patiala',
        doctorName: 'Dr. Manpreet Singh',
        summary: 'Metformin 500mg — Twice daily after meals',
        details: 'Metformin Hydrochloride 500mg tablets. Take one tablet twice daily after meals. Duration: 90 days. Refill as needed.',
        fhirData: {
          'resourceType': 'MedicationRequest',
          'id': 'med-001',
          'status': 'active',
          'intent': 'order',
          'medicationCodeableConcept': {
            'coding': [
              {'system': 'http://snomed.info/sct', 'code': '109081006', 'display': 'Metformin'}
            ]
          },
          'dosageInstruction': [
            {
              'text': '500mg twice daily after meals',
              'timing': {'repeat': {'frequency': 2, 'period': 1, 'periodUnit': 'd'}},
            }
          ],
        },
      ),
      AbhaRecordModel(
        id: 'ABHA-REC-003',
        type: 'diagnostic',
        abhaId: abhaId,
        patientName: 'Sukhwinder Kaur',
        date: DateTime(2024, 10, 22),
        facilityName: 'City Lab & Diagnostics, Nabha',
        doctorName: 'Dr. Ravinder Kaur',
        summary: 'Complete Blood Count — All values within normal range',
        details: 'Hemoglobin: 12.5 g/dL (N: 12-16)\nRBC: 4.5 M/µL (N: 4.0-5.5)\nWBC: 7,200/µL (N: 4,000-11,000)\nPlatelets: 2.5 L/µL (N: 1.5-4.0)\nESR: 12 mm/hr (N: 0-20)',
        fhirData: {
          'resourceType': 'DiagnosticReport',
          'id': 'diag-001',
          'status': 'final',
          'code': {
            'coding': [
              {'system': 'http://loinc.org', 'code': '58410-2', 'display': 'Complete blood count'}
            ]
          },
          'result': [
            {'reference': 'Observation/obs-hb', 'display': 'Hemoglobin 12.5 g/dL'},
            {'reference': 'Observation/obs-rbc', 'display': 'RBC 4.5 M/µL'},
            {'reference': 'Observation/obs-wbc', 'display': 'WBC 7,200/µL'},
          ],
        },
      ),
      AbhaRecordModel(
        id: 'ABHA-REC-004',
        type: 'condition',
        abhaId: abhaId,
        patientName: 'Sukhwinder Kaur',
        date: DateTime(2024, 8, 5),
        facilityName: 'PHC Nabha',
        doctorName: 'Dr. Gurjeet Singh',
        summary: 'Hypertension Stage 1 — BP 145/92 mmHg',
        details: 'Patient presented with sustained elevated BP readings over 3 visits. Started on Amlodipine 5mg OD. Advised salt reduction and DASH diet.',
        fhirData: {
          'resourceType': 'Condition',
          'id': 'cond-002',
          'clinicalStatus': {'coding': [{'code': 'active'}]},
          'code': {
            'coding': [
              {'system': 'http://snomed.info/sct', 'code': '38341003', 'display': 'Hypertension'}
            ]
          },
        },
      ),
      AbhaRecordModel(
        id: 'ABHA-REC-005',
        type: 'imaging',
        abhaId: abhaId,
        patientName: 'Sukhwinder Kaur',
        date: DateTime(2024, 6, 12),
        facilityName: 'Rajindra Hospital, Patiala',
        doctorName: 'Dr. Amrit Pal',
        summary: 'Chest X-Ray PA View — Normal study, no active disease',
        details: 'Heart size normal. Both lung fields clear. No pleural effusion. Mediastinum normal. Bony thorax intact. Impression: Normal chest radiograph.',
        fhirData: {
          'resourceType': 'ImagingStudy',
          'id': 'img-001',
          'status': 'available',
          'modality': [
            {'system': 'http://dicom.nema.org/resources/ontology/DCM', 'code': 'CR'}
          ],
          'description': 'Chest X-Ray PA View',
        },
      ),
      AbhaRecordModel(
        id: 'ABHA-REC-006',
        type: 'medication',
        abhaId: abhaId,
        patientName: 'Sukhwinder Kaur',
        date: DateTime(2024, 8, 5),
        facilityName: 'PHC Nabha',
        doctorName: 'Dr. Gurjeet Singh',
        summary: 'Amlodipine 5mg — Once daily in the morning',
        details: 'Amlodipine Besylate 5mg tablets. Take one tablet once daily in the morning. Duration: Ongoing. Monitor BP weekly.',
        fhirData: {
          'resourceType': 'MedicationRequest',
          'id': 'med-002',
          'status': 'active',
          'intent': 'order',
          'medicationCodeableConcept': {
            'coding': [
              {'system': 'http://snomed.info/sct', 'code': '386864001', 'display': 'Amlodipine'}
            ]
          },
        },
      ),
      AbhaRecordModel(
        id: 'ABHA-REC-007',
        type: 'diagnostic',
        abhaId: abhaId,
        patientName: 'Sukhwinder Kaur',
        date: DateTime(2024, 11, 10),
        facilityName: 'City Lab & Diagnostics, Nabha',
        doctorName: 'Dr. Manpreet Singh',
        summary: 'HbA1c — 7.2% (Pre-diabetic to Diabetic range)',
        details: 'Glycated Hemoglobin (HbA1c): 7.2% (Target <7.0%)\nFasting Blood Sugar: 142 mg/dL (N: 70-100)\nPost-Prandial Blood Sugar: 210 mg/dL (N: <140)',
        fhirData: {
          'resourceType': 'DiagnosticReport',
          'id': 'diag-002',
          'status': 'final',
          'code': {
            'coding': [
              {'system': 'http://loinc.org', 'code': '4548-4', 'display': 'Hemoglobin A1c'}
            ]
          },
        },
      ),
    ];
  }
}

class ABDMFetchResult {
  final String patientName;
  final String abhaId;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String address;
  final List<AbhaRecordModel> records;

  ABDMFetchResult({
    required this.patientName,
    required this.abhaId,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.records,
  });
}
