import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const List<String> loginCarImages = [
    'assets/images/login_cars/carro1.jpg',
    'assets/images/login_cars/carro2.jpg',
    'assets/images/login_cars/carro3.jpg',
    'assets/images/login_cars/carro4.jpg',
    'assets/images/login_cars/carro5.jpg',
  ];

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  late final Timer _imageTimer;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _selectedImageIndex =
            (_selectedImageIndex + 1) % loginCarImages.length;
      });
    });
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      await AuthService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1976D2);
    const background = Color(0xFF070B12);
    const panel = Color(0xFF101722);
    const muted = Color(0xFF9AA7B8);

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color(0xFF2B3645),
      ),
    );

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;

            return Stack(
              children: [
                Positioned(
                  top: -150,
                  right: compact ? -180 : -80,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: blue.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 20 : 32,
                      vertical: 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1080,
                      ),
                      child: compact
                          ? Column(
                              children: [
                                _visualPanel(blue, true),
                                const SizedBox(height: 20),
                                _loginContent(
                                  panel,
                                  blue,
                                  muted,
                                  fieldBorder,
                                  null,
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _visualPanel(
                                    blue,
                                    compact,
                                  ),
                                ),
                                const SizedBox(width: 72),
                                SizedBox(
                                  width: 420,
                                  child: _loginContent(
                                    panel,
                                    blue,
                                    muted,
                                    fieldBorder,
                                    null,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _visualPanel(Color blue, bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          // LOGO DA ESQUERDA
          // Alterada somente aqui para "Luciooo".
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
              children: [
                TextSpan(
                  text: 'Projeto',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'UPF',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
         
        ],
        const SizedBox(height: 36),
        Container(
          height: compact ? 210 : 330,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: blue.withValues(alpha: 0.18),
            ),
            gradient: LinearGradient(
              colors: [
                blue.withValues(alpha: 0.16),
                const Color(0xFF121C2A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (
                    currentChild,
                    previousChildren,
                  ) =>
                      Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ...previousChildren,
                      currentChild ?? const SizedBox.shrink(),
                    ],
                  ),
                  child: Image.asset(
                    loginCarImages[_selectedImageIndex],
                    key: ValueKey(
                      loginCarImages[_selectedImageIndex],
                    ),
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.62),
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) =>
                        const ColoredBox(
                      color: Color(0xFF121C2A),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF070B12)
                            .withValues(alpha: 0.92),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const Positioned(
                  left: 24,
                  bottom: 22,
                  child: Text(
                    'Mais controle.\nMais tranquilidade.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ),
                Positioned(
                  right: 24,
                  top: 24,
                  child: Icon(
                    Icons.directions_car_filled,
                    color: blue,
                    size: 30,
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 14,
                  child: Row(
                    children: [
                      for (
                        var index = 0;
                        index < loginCarImages.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 220,
                              ),
                              width: index == _selectedImageIndex
                                  ? 22
                                  : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: index == _selectedImageIndex
                                    ? blue
                                    : Colors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Esta função continua sendo usada pela logo da DIREITA.
  Widget _brandMark(Color blue, double size) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        children: [
          const TextSpan(
            text: 'Auto',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: 'Hub',
            style: TextStyle(
              color: blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginContent(
    Color panel,
    Color blue,
    Color muted,
    OutlineInputBorder fieldBorder,
    Object? unused,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF202B39),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LOGO DA DIREITA - CONTINUA AutoHub
            _brandMark(blue, 30),
            const SizedBox(height: 6),
            Text(
              'Seu carro sempre em dia',
              style: TextStyle(
                color: muted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Olá!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Faça login para acessar sua conta do AutoHub.',
              style: TextStyle(
                color: muted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: _inputDecoration(
                'E-mail',
                Icons.email_outlined,
                fieldBorder,
                blue,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Informe seu e-mail.';
                }

                if (!value.contains('@')) {
                  return 'E-mail inválido.';
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: _inputDecoration(
                'Senha',
                Icons.lock_outline,
                fieldBorder,
                blue,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                  color: muted,
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe sua senha.';
                }

                if (value.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres.';
                }

                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ForgotPasswordScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Esqueci minha senha',
                ),
              ),
            ),
            const SizedBox(height: 6),
            FilledButton.icon(
              onPressed: _loading ? null : _login,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_rounded,
                    ),
              label: Text(
                _loading ? 'Entrando...' : 'Entrar',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    blue.withValues(alpha: 0.45),
                minimumSize:
                    const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment:
                  WrapCrossAlignment.center,
              children: [
                Text(
                  'Não tem uma conta? ',
                  style: TextStyle(
                    color: muted,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RegisterScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: blue,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
    OutlineInputBorder border,
    Color accent,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF7D8A9B),
      ),
      prefixIcon: Icon(
        icon,
        color: accent,
      ),
      filled: true,
      fillColor: const Color(0xFF0B111A),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(
          color: accent,
          width: 1.4,
        ),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(
          color: Color(0xFFFF6B6B),
        ),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(
          color: Color(0xFFFF6B6B),
          width: 1.4,
        ),
      ),
    );
  }
}