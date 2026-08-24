import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccessToken = 'ms_access_token';
const _kRefreshToken = 'ms_refresh_token';
const _kUserId = 'ms_user_id';

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);
  Future<String?> getUserId() => _storage.read(key: _kUserId);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    // Write sequentially — flutter_secure_storage on web generates an
    // encryption key on the first write. Concurrent writes race to create
    // different keys, leaving earlier values undecryptable.
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
    if (userId != null) {
      await _storage.write(key: _kUserId, value: userId);
    }
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kUserId),
    ]);
  }

  Future<bool> get isLoggedIn async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
