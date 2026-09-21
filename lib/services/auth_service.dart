import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool get isFirebaseReady => Firebase.apps.isNotEmpty;

  static User? get currentUser {
    if (!isFirebaseReady) {
      return null;
    }

    return _auth.currentUser;
  }

  static Stream<User?> get authStateChanges {
    if (!isFirebaseReady) {
      return const Stream.empty();
    }

    return _auth.authStateChanges();
  }

  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  static Future<UserCredential> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final cleanName = name.trim();
      if (cleanName.isNotEmpty) {
        await credential.user?.updateDisplayName(cleanName);
        await credential.user?.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    try {
      await user.updateDisplayName(name.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  static Future<void> updatePassword(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    try {
      await user.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyErrorMessage(e));
    }
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw Exception('Não foi possível identificar o e-mail da conta.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Senha atual incorreta.');
        case 'requires-recent-login':
          throw Exception('Por segurança, faça login novamente e tente trocar sua senha.');
        case 'weak-password':
          throw Exception('A nova senha não atende aos requisitos de segurança.');
        default:
          throw Exception('Não foi possível alterar a senha. Tente novamente.');
      }
    }
  }

  static String _friendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'O e-mail informado é inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Verifique os dados e tente novamente.';
      case 'email-already-in-use':
        return 'Este e-mail já está sendo usado por outra conta.';
      case 'weak-password':
        return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Login com e-mail e senha está desabilitado neste momento.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'requires-recent-login':
        return 'Faça login novamente para concluir esta ação.';
      default:
        return 'Não foi possível concluir a operação. Tente novamente.';
    }
  }
}
