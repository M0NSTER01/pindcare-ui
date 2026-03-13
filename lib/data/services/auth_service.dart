import 'package:hive/hive.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import '../local/hive_service.dart';

/// Handles login/register, JWT token lifecycle, and logged-in user state.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Returns true if a JWT is stored (used for auto-login check).
  Future<bool> get isLoggedIn async {
    final tok = await ApiService().getStoredToken();
    return tok != null;
  }

  /// Register via backend, cache user locally, return user model.
  Future<UserModel> register(Map<String, dynamic> userData) async {
    final data = await ApiService().register(userData);
    final user = _parseUser(data);
    await _cacheUser(user);
    _currentUser = user;
    return user;
  }

  /// Login via backend, cache user locally, return user model.
  Future<UserModel> login(String phone, String password) async {
    final data = await ApiService().login(phone, password);
    final user = _parseUser(data);
    await _cacheUser(user);
    _currentUser = user;
    return user;
  }

  /// Load the user cached in Hive (used on app re-launch).
  UserModel? loadCachedUser() {
    final box = HiveService.getBox(HiveService.usersBox);
    if (box.isEmpty) return null;
    try {
      final map = Map<String, dynamic>.from(box.values.first as Map);
      _currentUser = UserModel.fromMap(map);
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Logout: clear JWT + cached user.
  Future<void> logout() async {
    await ApiService().logout();
    await HiveService.clear(HiveService.usersBox);
    _currentUser = null;
  }

  UserModel _parseUser(Map<String, dynamic> data) {
    // Backend may return user inside data.user or at root
    final userMap = data['user'] != null
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;
    return UserModel.fromMap(userMap);
  }

  Future<void> _cacheUser(UserModel user) async {
    await HiveService.put(HiveService.usersBox, 'current_user', user.toMap());
    await HiveService.setUserRole(user.role);
    await HiveService.setRegistrationComplete(true);
  }
}
