import 'package:flutter/services.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  static String messageForCode(String code) => switch (code) {
    'INVALID_CREDENTIAL' ||
    'ERROR_INVALID_CREDENTIAL' ||
    'ERROR_USER_NOT_FOUND' ||
    'ERROR_WRONG_PASSWORD' => 'Email atau password tidak sesuai.',
    'TOO_MANY_REQUESTS' ||
    'ERROR_TOO_MANY_REQUESTS' => 'Terlalu banyak percobaan. Coba lagi nanti.',
    'NETWORK_ERROR' ||
    'ERROR_NETWORK_REQUEST_FAILED' => 'Tidak dapat menghubungi layanan login.',
    'FIREBASE_NOT_CONFIGURED' =>
      'Firebase belum dikonfigurasi pada aplikasi ini.',
    _ => 'Login tidak dapat diproses. Coba lagi.',
  };

  @override
  String toString() => message;
}

abstract class AuthService {
  Future<bool> isConfigured();
  Future<bool> isSignedIn();
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}

class PlatformAuthService implements AuthService {
  static const _channel = MethodChannel('nekouse/firebase_auth');

  @override
  Future<bool> isConfigured() async =>
      await _channel.invokeMethod<bool>('isConfigured') ?? false;

  @override
  Future<bool> isSignedIn() async =>
      await _channel.invokeMethod<bool>('isSignedIn') ?? false;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _channel.invokeMethod<void>('signIn', {
        'email': email,
        'password': password,
      });
    } on PlatformException catch (error) {
      throw AuthFailure(AuthFailure.messageForCode(error.code));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _channel.invokeMethod<void>('signOut');
    } on PlatformException catch (error) {
      throw AuthFailure(AuthFailure.messageForCode(error.code));
    }
  }
}

class MemoryAuthService implements AuthService {
  MemoryAuthService({this.configured = true, this.signedIn = false});

  bool configured;
  bool signedIn;
  AuthFailure? nextFailure;

  @override
  Future<bool> isConfigured() async => configured;

  @override
  Future<bool> isSignedIn() async => signedIn;

  @override
  Future<void> signIn({required String email, required String password}) async {
    final failure = nextFailure;
    nextFailure = null;
    if (failure != null) throw failure;
    signedIn = true;
  }

  @override
  Future<void> signOut() async => signedIn = false;
}
