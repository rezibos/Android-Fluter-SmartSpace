import 'package:flutter/material.dart';

import '../models/login_input.dart';
import '../theme/space_theme.dart';

typedef LoginCallback = Future<String?> Function(
  String host,
  String email,
  String password,
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.firebaseReady,
    required this.initialHost,
    required this.onLogin,
    required this.onAuthenticated,
  });

  final bool firebaseReady;
  final String initialHost;
  final LoginCallback onLogin;
  final VoidCallback onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hostController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _animation;
  bool _obscurePassword = true;
  bool _loading = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.initialHost);
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await widget.onLogin(
      _hostController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    setState(() {
      _loading = false;
      _success = true;
    });
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.duration = const Duration(milliseconds: 120);
    }
    await _animation.forward();
    if (mounted) widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
      final progress = Curves.easeOutCubic.transform(_animation.value);
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color.lerp(
          context.space.background,
          context.space.active,
          progress,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Opacity(opacity: 1 - progress, child: child),
              if (_success)
                Center(
                  child: Transform.scale(
                    scale: 1 + (progress * 3.5),
                    child: Image.asset(
                      'assets/branding/nekouse_login.png',
                      width: 150,
                      semanticLabel: 'Logo Nekouse',
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/branding/nekouse_login.png',
                  height: 150,
                  semanticLabel: 'Logo Nekouse',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selamat datang',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Masuk untuk mengendalikan Smart Space',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.space.inkMuted),
                ),
                const SizedBox(height: 28),
                if (!widget.firebaseReady || _error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SpacePalette.dangerBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.firebaseReady
                          ? _error!
                          : 'Firebase belum dikonfigurasi pada aplikasi ini.',
                      style: const TextStyle(
                        color: SpacePalette.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _hostController,
                  validator: LoginInput.validateHost,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'IP ESP32',
                    hintText: '192.168.1.10',
                    prefixIcon: Icon(Icons.hub_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  validator: LoginInput.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  validator: LoginInput.validatePassword,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Tampilkan password'
                          : 'Sembunyikan password',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: widget.firebaseReady && !_loading
                        ? _submit
                        : null,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Masuk'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
