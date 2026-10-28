class AuthValidators {
  const AuthValidators._();

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.length < 8 ||
        password.length > 128 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[^A-Za-z0-9\s]').hasMatch(password)) {
      return 'Usa de 8 a 128 caracteres, mayúscula, minúscula, número y símbolo.';
    }
    return null;
  }

  // Existing accounts must still be able to sign in with their original password.
  static String? loginPassword(String? value) =>
      (value ?? '').isEmpty ? 'Ingresa tu contraseña.' : null;

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }
}
