import '../../../core/network/api_client.dart';

enum AccountRole {
  supervisor('Supervisor'),
  admin('Administrador'),
  operator('Operario');

  const AccountRole(this.label);
  final String label;
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.refreshToken,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AuthSession.fromJson(Object? json) {
    if (json
        case {
          'token': final String token,
          'refreshToken': final String refreshToken,
          'fullName': final String name,
          'email': final String email,
          'role': final String role,
        }
        when token.isNotEmpty && refreshToken.isNotEmpty) {
      return AuthSession(
        token: token,
        refreshToken: refreshToken,
        name: name,
        email: email,
        role: switch (role) {
          'SUPERVISOR' => AccountRole.supervisor,
          'ADMIN' => AccountRole.admin,
          'OPERATOR' => AccountRole.operator,
          _ => throw const ApiException(
            'El servidor devolvió un rol desconocido.',
          ),
        },
      );
    }
    throw const ApiException('La API devolvió una sesión inválida.');
  }

  final String token;
  final String refreshToken;
  final String name;
  final String email;
  final AccountRole role;
}

class AuthRepository {
  const AuthRepository(this._api);

  final ApiClient _api;

  Future<AuthSession> signIn(String identifier, String password) async {
    final result = await _api.post(
      '/api/v1/auth/login',
      body: {'identifier': identifier, 'password': password},
    );
    return AuthSession.fromJson(result);
  }

  Future<void> signOut(AuthSession session) async {
    await _api.post(
      '/api/v1/auth/logout',
      body: {'refreshToken': session.refreshToken},
    );
  }
}
