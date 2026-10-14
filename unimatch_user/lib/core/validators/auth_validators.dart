class AuthValidators {
  const AuthValidators._();

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').length < 6) {
      return 'Usa al menos 6 caracteres.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return 'Las contrasenas no coinciden.';
    }
    return null;
  }
}
