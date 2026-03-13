import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/socket_service.dart';
import '../../data/services/sync_service.dart';

/// Auth state: holds the currently logged-in user (null = logged out).
class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null) {
    // Try restoring user from Hive on startup.
    final cached = AuthService().loadCachedUser();
    if (cached != null) state = cached;
  }

  Future<UserModel> login(String phone, String password) async {
    final user = await AuthService().login(phone, password);
    state = user;
    SocketService().connect(user.id);
    SyncService().watchConnectivity(user.id);
    return user;
  }

  Future<UserModel> register(Map<String, dynamic> userData) async {
    final user = await AuthService().register(userData);
    state = user;
    SocketService().connect(user.id);
    SyncService().watchConnectivity(user.id);
    return user;
  }

  Future<void> logout() async {
    SocketService().disconnect();
    await AuthService().logout();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (_) => AuthNotifier(),
);

/// Convenience provider — true if user is logged in.
final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(authProvider) != null,
);
