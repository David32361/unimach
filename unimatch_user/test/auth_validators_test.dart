import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/core/validators/auth_validators.dart';

void main() {
  test('validates email addresses', () {
    expect(AuthValidators.email('correo-invalido'), isNotNull);
    expect(AuthValidators.email('persona@universidad.mx'), isNull);
  });

  test('requires passwords with at least six characters', () {
    expect(AuthValidators.password('12345'), isNotNull);
    expect(AuthValidators.password('123456'), isNull);
  });

  test('requires matching password confirmation', () {
    expect(AuthValidators.confirmPassword('abcdef', '123456'), isNotNull);
    expect(AuthValidators.confirmPassword('123456', '123456'), isNull);
  });
}
