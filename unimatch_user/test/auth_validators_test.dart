import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/core/validators/auth_validators.dart';

void main() {
  test('validates email addresses', () {
    expect(AuthValidators.email('correo-invalido'), isNotNull);
    expect(AuthValidators.email('persona@universidad.mx'), isNull);
  });

  test('rejects weak new passwords and accepts the full policy', () {
    for (final password in [
      '123456',
      'Ab1!',
      'abcdefgh',
      'ABCDEFGH1!',
      'abcdefgh1!',
      'Abcdefgh!',
      'Abcdefgh1',
      'Ab1!${'x' * 125}',
    ]) {
      expect(AuthValidators.password(password), isNotNull, reason: password);
    }
    expect(AuthValidators.password('UniMatch2026!'), isNull);
  });

  test('legacy passwords remain valid at login', () {
    expect(AuthValidators.loginPassword('123456'), isNull);
    expect(AuthValidators.loginPassword(''), isNotNull);
  });

  test('requires matching password confirmation', () {
    expect(AuthValidators.confirmPassword('abcdef', '123456'), isNotNull);
    expect(AuthValidators.confirmPassword('123456', '123456'), isNull);
  });
}
