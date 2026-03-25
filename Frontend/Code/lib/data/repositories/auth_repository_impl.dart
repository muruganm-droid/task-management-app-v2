import '../api/api_client.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final ApiClient _apiClient;
  User? _cachedUser;

  AuthRepositoryImpl(this._authService, this._apiClient);

  @override
  bool get isAuthenticated => _apiClient.hasToken;

  @override
  User? get cachedUser => _cachedUser;

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _authService.register(
      name: name,
      email: email,
      password: password,
    );
    await _apiClient.saveTokens(
      response.tokens.accessToken,
      response.tokens.refreshToken,
    );
    _cachedUser = response.user;
    return response;
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(email: email, password: password);
    await _apiClient.saveTokens(
      response.tokens.accessToken,
      response.tokens.refreshToken,
    );
    _cachedUser = response.user;
    return response;
  }

  @override
  Future<void> logout() async {
    final refreshToken = _apiClient.refreshToken;
    if (refreshToken != null) {
      try {
        await _authService.logout(refreshToken);
      } catch (_) {
        // Best-effort logout on server
      }
    }
    await _apiClient.clearTokens();
    _cachedUser = null;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _authService.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _authService.resetPassword(token: token, newPassword: newPassword);
  }

  @override
  Future<User> getProfile() async {
    final user = await _authService.getProfile();
    _cachedUser = user;
    return user;
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    final user = await _authService.updateProfile(
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
    );
    _cachedUser = user;
    return user;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
