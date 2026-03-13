import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/patient_model.dart';
import '../../data/services/api_service.dart';

class AshaState {
  final List<PatientModel> managedPatients;
  final PatientModel? selectedPatient; // non-null = agent mode
  final bool isLoading;

  const AshaState({
    this.managedPatients = const [],
    this.selectedPatient,
    this.isLoading = false,
  });

  AshaState copyWith({
    List<PatientModel>? managedPatients,
    PatientModel? selectedPatient,
    bool clearSelected = false,
    bool? isLoading,
  }) =>
      AshaState(
        managedPatients: managedPatients ?? this.managedPatients,
        selectedPatient:
            clearSelected ? null : (selectedPatient ?? this.selectedPatient),
        isLoading: isLoading ?? this.isLoading,
      );

  bool get isAgentMode => selectedPatient != null;
}

class AshaNotifier extends StateNotifier<AshaState> {
  AshaNotifier() : super(const AshaState());

  Future<void> loadManagedPatients() async {
    state = state.copyWith(isLoading: true);
    try {
      final patients = await ApiService().getManagedPatients();
      final models = patients
          .map((p) =>
              PatientModel.fromMap(Map<String, dynamic>.from(p as Map)))
          .toList();
      state = state.copyWith(managedPatients: models, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addPatient(Map<String, dynamic> data) async {
    await ApiService().addManagedPatient(data);
    await loadManagedPatients();
  }

  void selectPatient(PatientModel? patient) {
    if (patient == null) {
      state = state.copyWith(clearSelected: true);
    } else {
      state = state.copyWith(selectedPatient: patient);
    }
  }

  void exitAgentMode() => state = state.copyWith(clearSelected: true);

  /// Returns the patient ID to use for API calls.
  /// In agent mode, returns selected patient's ID; otherwise the ASHA's own ID.
  String effectivePatientId(String ashaOwnId) =>
      state.selectedPatient?.id ?? ashaOwnId;
}

final ashaProvider = StateNotifierProvider<AshaNotifier, AshaState>(
  (_) => AshaNotifier(),
);
