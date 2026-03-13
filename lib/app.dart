import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/ai_scan/ai_scan_screen.dart';
import 'features/ai_scan/analyzing_screen.dart';
import 'features/ai_scan/diagnosis_result_screen.dart';
import 'features/ai_scan/symptom_checker_screen.dart';
import 'features/health_records/health_records_screen.dart';
import 'features/health_records/record_detail_screen.dart';
import 'features/medicines/medicines_screen.dart';
import 'features/consultation/consultation_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/registration/role_selection_screen.dart';
import 'features/registration/doctor_registration_screen.dart';
import 'features/registration/patient_registration_screen.dart';
import 'features/registration/asha_registration_screen.dart';
import 'features/doctor/doctor_dashboard_screen.dart';
import 'features/doctor/doctor_appointments_screen.dart';
import 'features/doctor/doctor_patients_screen.dart';
import 'features/doctor/doctor_profile_screen.dart';
import 'features/doctor/doctor_write_prescription_screen.dart';
import 'features/doctor/abdm_patient_history_screen.dart';
import 'features/video_call/video_call_screen.dart';
import 'features/chat/chat_screens.dart';
import 'features/map/offline_map_screen.dart';
import 'features/asha/managed_patients_screen.dart';
import 'features/pharmacy/pharmacy_stock_screen.dart';
import 'shared/widgets/main_shell.dart';
import 'shared/widgets/doctor_shell.dart';

CustomTransitionPage _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (c, a, s, w) => FadeTransition(opacity: a, child: w),
    );

CustomTransitionPage _slidePage(GoRouterState state, Widget child,
    {Offset begin = const Offset(1, 0)}) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (c, a, s, w) => SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
        child: w,
      ),
    );

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', pageBuilder: (c, s) => _fadePage(s, const SplashScreen())),
    GoRoute(path: '/onboarding', pageBuilder: (c, s) => _fadePage(s, const OnboardingScreen())),

    // Registration routes
    GoRoute(path: '/role-selection', pageBuilder: (c, s) => _fadePage(s, const RoleSelectionScreen())),
    GoRoute(path: '/register/doctor', pageBuilder: (c, s) => _slidePage(s, const DoctorRegistrationScreen())),
    GoRoute(path: '/register/patient', pageBuilder: (c, s) => _slidePage(s, const PatientRegistrationScreen())),
    GoRoute(path: '/register/asha', pageBuilder: (c, s) => _slidePage(s, const AshaRegistrationScreen())),

    // Patient/ASHA shell
    ShellRoute(
      builder: (c, state, child) => MainShell(state: state, child: child),
      routes: [
        GoRoute(path: '/home', pageBuilder: (c, s) => _fadePage(s, const HomeScreen())),
        GoRoute(path: '/health-records', pageBuilder: (c, s) => _fadePage(s, const HealthRecordsScreen())),
        GoRoute(path: '/medicines', pageBuilder: (c, s) => _fadePage(s, const MedicinesScreen())),
        GoRoute(path: '/profile', pageBuilder: (c, s) => _fadePage(s, const ProfileScreen())),
      ],
    ),

    // Doctor shell
    ShellRoute(
      builder: (c, state, child) => DoctorShell(state: state, child: child),
      routes: [
        GoRoute(path: '/doctor/dashboard', pageBuilder: (c, s) => _fadePage(s, const DoctorDashboardScreen())),
        GoRoute(path: '/doctor/appointments', pageBuilder: (c, s) => _fadePage(s, const DoctorAppointmentsScreen())),
        GoRoute(path: '/doctor/patients', pageBuilder: (c, s) => _fadePage(s, const DoctorPatientsScreen())),
        GoRoute(path: '/doctor/messages', pageBuilder: (c, s) => _fadePage(s, const ChatListScreen())),
        GoRoute(path: '/doctor/profile', pageBuilder: (c, s) => _fadePage(s, const DoctorProfileScreen())),
      ],
    ),

    // Full-screen routes
    GoRoute(path: '/ai-scan', pageBuilder: (c, s) => _slidePage(s, const AiScanScreen(), begin: const Offset(0, 1))),
    GoRoute(path: '/ai-scan/analyzing', pageBuilder: (c, s) => _fadePage(s, const AnalyzingScreen())),
    GoRoute(path: '/ai-scan/result', pageBuilder: (c, s) => _slidePage(s, const DiagnosisResultScreen())),
    GoRoute(path: '/symptom-checker', pageBuilder: (c, s) => _slidePage(s, const SymptomCheckerScreen())),
    GoRoute(path: '/consultation', pageBuilder: (c, s) => _slidePage(s, const ConsultationScreen())),
    GoRoute(path: '/video-call', pageBuilder: (c, s) => _fadePage(s, const VideoCallScreen())),
    GoRoute(path: '/chat', pageBuilder: (c, s) => _slidePage(s, const ChatListScreen())),
    GoRoute(path: '/map', pageBuilder: (c, s) => _slidePage(s, const OfflineMapScreen())),
    GoRoute(path: '/abdm-history', pageBuilder: (c, s) => _slidePage(s, const AbdmPatientHistoryScreen())),
    GoRoute(path: '/asha/patients', pageBuilder: (c, s) => _slidePage(s, const ManagedPatientsScreen())),
    GoRoute(path: '/pharmacy/stock', pageBuilder: (c, s) => _slidePage(s, const PharmacyStockScreen())),
    GoRoute(path: '/record/:type', pageBuilder: (c, s) {
      final type = s.pathParameters['type'] ?? 'consultation';
      return _slidePage(s, RecordDetailScreen(recordType: type));
    }),
    GoRoute(path: '/doctor/write-prescription', pageBuilder: (c, s) => _slidePage(s, const DoctorWritePrescriptionScreen())),
    GoRoute(path: '/doctor/patient-detail', pageBuilder: (c, s) => _slidePage(s, const RecordDetailScreen(recordType: 'consultation'))),
  ],
);

class ArogyaLinkApp extends StatelessWidget {
  const ArogyaLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ArogyaLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
