import '../../data/models/auth_response.dart';
import '../../data/models/user.dart';

abstract class AuthRepository {
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  });
  Future<AuthResponse> login({required String email, required String password});
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
  Future<User> getProfile();
  Future<User> updateProfile({String? name, String? bio, String? avatarUrl});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  bool get isAuthenticated;
  User? get cachedUser;
}
