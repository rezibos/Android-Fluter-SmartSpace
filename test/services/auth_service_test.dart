import 'package:flutter_test/flutter_test.dart';
import 'package:witdget/services/auth_service.dart';

void main() {
  test('maps Firebase errors to safe messages', () {
    expect(
      AuthFailure.messageForCode('ERROR_INVALID_CREDENTIAL'),
      'Email atau password tidak sesuai.',
    );
    expect(
      AuthFailure.messageForCode('ERROR_TOO_MANY_REQUESTS'),
      'Terlalu banyak percobaan. Coba lagi nanti.',
    );
    expect(
      AuthFailure.messageForCode('NETWORK_ERROR'),
      'Tidak dapat menghubungi layanan login.',
    );
  });

  test('memory auth persists sign-in state', () async {
    final auth = MemoryAuthService();
    expect(await auth.isSignedIn(), isFalse);
    await auth.signIn(email: 'user@example.com', password: 'rahasia');
    expect(await auth.isSignedIn(), isTrue);
    await auth.signOut();
    expect(await auth.isSignedIn(), isFalse);
  });
}
