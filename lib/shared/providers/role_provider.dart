import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/hive_service.dart';

final roleProvider = StateProvider<String>((ref) {
  return HiveService.getUserRole() ?? 'patient';
});

final isOnboardingCompleteProvider = StateProvider<bool>((ref) {
  return HiveService.isOnboardingComplete();
});

final isRegistrationCompleteProvider = StateProvider<bool>((ref) {
  return HiveService.isRegistrationComplete();
});
