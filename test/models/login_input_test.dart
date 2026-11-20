import 'package:flutter_test/flutter_test.dart';
import 'package:witdget/models/login_input.dart';

void main() {
  test('validates ESP32 host, email, and password', () {
    expect(LoginInput.validateHost('192.168.1.10'), isNull);
    expect(LoginInput.validateHost('esp32.local'), isNull);
    expect(LoginInput.validateHost('http://192.168.1.10/path'), isNotNull);
    expect(LoginInput.validateEmail('user@example.com'), isNull);
    expect(LoginInput.validateEmail('user'), isNotNull);
    expect(LoginInput.validatePassword(''), isNotNull);
    expect(LoginInput.validatePassword('rahasia'), isNull);
  });
}
