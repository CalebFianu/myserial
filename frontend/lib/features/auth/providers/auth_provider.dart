import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/secure_storage.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.handle,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String name;
  final String email;
  final String handle;
  final String? avatarUrl;
  final String? bio;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        handle: json['handle'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
      );
}

sealed class AuthState {
  const AuthState();
}

class AuthStateGuest extends AuthState {
  const AuthStateGuest();
}

class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);
  final AuthUser user;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.watch(secureStorageProvider);
    final isLoggedIn = await storage.isLoggedIn;
    if (!isLoggedIn) return const AuthStateGuest();

    try {
      final api = ref.read(apiClientProvider);
      final data = await api.get<Map<String, dynamic>>('/auth/me');
      return AuthStateAuthenticated(AuthUser.fromJson(data));
    } catch (_) {
      return const AuthStateGuest();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final data = await api.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final storage = ref.read(secureStorageProvider);
      await storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        userId: (data['user'] as Map<String, dynamic>)['id'] as String,
      );
      return AuthStateAuthenticated(
        AuthUser.fromJson(data['user'] as Map<String, dynamic>),
      );
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final data = await api.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      final storage = ref.read(secureStorageProvider);
      await storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        userId: (data['user'] as Map<String, dynamic>)['id'] as String,
      );
      return AuthStateAuthenticated(
        AuthUser.fromJson(data['user'] as Map<String, dynamic>),
      );
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(apiClientProvider).post<void>('/auth/logout');
    } catch (_) {}
    await ref.read(secureStorageProvider).clearTokens();
    state = const AsyncData(AuthStateGuest());
  }
}
