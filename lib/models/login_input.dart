class LoginInput {
  static String? validateHost(String? value) {
    final host = value?.trim() ?? '';
    if (host.isEmpty) return 'Alamat IP ESP32 wajib diisi.';
    if (!RegExp(r'^[a-zA-Z0-9.-]+$').hasMatch(host)) {
      return 'Masukkan IP atau hostname tanpa http dan path.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }

  static String? validatePassword(String? value) =>
      (value ?? '').isEmpty ? 'Password wajib diisi.' : null;
}
