import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';

// State: currently logged-in user or null
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier()..restoreSession(),
);

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null);

  /// Restore from Hive on cold start
  Future<void> restoreSession() async {
    try {
      final box   = Hive.box('user_box');
      final token = box.get('token') as String?;
      final id    = box.get('userId') as String?;
      final name  = box.get('userName') as String?;
      final role  = box.get('role') as String?;
      final phone = box.get('phone') as String?;
      if (token != null && id != null && name != null) {
        state = UserModel(
          id: id, name: name, phone: phone ?? '', role: role ?? 'patient',
          gender: '', village: '', district: '', state: 'Punjab',
          bloodGroup: '', emergencyContact: '', emergencyContactName: '',
        );
      }
    } catch (_) {}
  }

  /// Login — calls backend and caches JWT in Hive
  Future<UserModel> login(String phone, String password) async {
    final data = await ApiService().login(phone, password);

    final token    = data['token'] as String;
    final userData = Map<String, dynamic>.from(data['user'] as Map);

    // Persist to Hive
    final box = Hive.box('user_box');
    await box.put('token', token);
    await box.put('userId', userData['id'].toString());
    await box.put('userName', userData['name'] ?? '');
    await box.put('role', userData['role'] ?? 'patient');
    await box.put('phone', phone);

    // Update ApiService so all future requests carry the JWT
    ApiService().setToken(token);

    final user = UserModel(
      id: userData['id'].toString(),
      name: userData['name'] ?? '',
      phone: phone,
      role: userData['role'] ?? 'patient',
      gender: '', village: userData['village'] ?? '',
      district: userData['district'] ?? '', state: 'Punjab',
      bloodGroup: '', emergencyContact: '', emergencyContactName: '',
    );
    state = user;
    return user;
  }

  /// Register — calls backend and auto-logs-in
  Future<UserModel> register(Map<String, dynamic> payload) async {
    final data = await ApiService().register(payload);

    final token    = data['token'] as String;
    final userData = Map<String, dynamic>.from(data['user'] as Map);

    final box = Hive.box('user_box');
    await box.put('token', token);
    await box.put('userId', userData['id'].toString());
    await box.put('userName', userData['name'] ?? '');
    await box.put('role', userData['role'] ?? 'patient');
    await box.put('phone', payload['phone_number'] ?? '');

    ApiService().setToken(token);

    final user = UserModel(
      id: userData['id'].toString(),
      name: userData['name'] ?? '',
      phone: payload['phone_number'] ?? '',
      role: userData['role'] ?? 'patient',
      gender: payload['gender'] ?? '',
      village: payload['village'] ?? '',
      district: payload['district'] ?? '', state: 'Punjab',
      bloodGroup: '', emergencyContact: '', emergencyContactName: '',
    );
    state = user;
    return user;
  }

  /// Logout — clears Hive and state
  Future<void> logout() async {
    final box = Hive.box('user_box');
    await box.delete('token');
    await box.delete('userId');
    await box.delete('userName');
    await box.delete('role');
    await box.delete('phone');
    ApiService().setToken('');
    state = null;
  }
}
