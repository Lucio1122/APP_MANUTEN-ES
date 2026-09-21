import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';

import 'reports_screen.dart';
import 'credits_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profilePhoto;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final photo = await StorageService.getProfilePhoto();
    if (mounted) {
      setState(() => _profilePhoto = photo);
    }
  }

  Future<void> _changePhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;

    final photo = base64Encode(await file.readAsBytes());

    await StorageService.saveProfilePhoto(photo);

    if (mounted) {
      setState(() => _profilePhoto = photo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto atualizada com sucesso.'),
        ),
      );
    }
  }

  Future<void> _changeName() async {
    final user = AuthService.currentUser;

    if (user == null) return;

    final controller = TextEditingController(
      text: user.displayName ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar nome'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      await AuthService.updateDisplayName(controller.text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome atualizado com sucesso.'),
        ),
      );

      setState(() {});
    } on Exception catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  }

  Future<void> _openReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportsScreen(),
      ),
    );
  }

  Future<void> _openCredits() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreditsScreen(),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _changePhoto,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: _profilePhoto == null
                            ? null
                            : MemoryImage(
                                base64Decode(_profilePhoto!),
                              ),
                        child: _profilePhoto == null
                            ? const Icon(
                                Icons.person,
                                size: 32,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName?.isNotEmpty == true
                          ? user!.displayName!
                          : 'Usuário',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? 'Sem e-mail',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Alterar foto'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePhoto,
            ),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Alterar nome'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changeName,
            ),

            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Alterar senha'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePassword,
            ),

            // ==============================
            // RELATÓRIOS
            // ==============================
            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: const Text('Relatórios'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openReport,
            ),

            // ==============================
            // CRÉDITOS
            // ==============================
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Créditos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openCredits,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: Colors.red,
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController =
      TextEditingController();

  final _newPasswordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _loading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso!'),
        ),
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 700),
      );

      if (mounted) {
        Navigator.pop(context);
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trocar senha'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_reset_rounded,
                  size: 64,
                  color: Color(0xFF1976D2),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Trocar senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Altere sua senha para manter\nsua conta segura.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 28),

                _passwordField(
                  controller:
                      _currentPasswordController,
                  label: 'Senha atual',
                  hint: 'Digite sua senha atual',
                  obscureText:
                      _obscureCurrentPassword,
                  onToggle: () {
                    setState(
                      () => _obscureCurrentPassword =
                          !_obscureCurrentPassword,
                    );
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Digite sua senha atual.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _passwordField(
                  controller:
                      _newPasswordController,
                  label: 'Nova senha',
                  hint: 'Digite sua nova senha',
                  obscureText:
                      _obscureNewPassword,
                  onToggle: () {
                    setState(
                      () => _obscureNewPassword =
                          !_obscureNewPassword,
                    );
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Digite uma nova senha.';
                    }

                    if (value.length < 6) {
                      return 'Essa senha não atende aos requisitos necessários.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _passwordField(
                  controller:
                      _confirmPasswordController,
                  label: 'Confirmar nova senha',
                  hint: 'Digite novamente sua nova senha',
                  obscureText:
                      _obscureConfirmPassword,
                  onToggle: () {
                    setState(
                      () => _obscureConfirmPassword =
                          !_obscureConfirmPassword,
                    );
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Confirme sua nova senha.';
                    }

                    if (value !=
                        _newPasswordController.text) {
                      return 'As novas senhas não são iguais.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  onPressed:
                      _loading ? null : _changePassword,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _loading
                        ? 'Alterando senha...'
                        : 'ALTERAR SENHA',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(
          Icons.lock_outline,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}