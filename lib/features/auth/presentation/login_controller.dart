import 'package:flutter/material.dart';
import 'package:delivery_app/features/auth/data/auth_service.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loginWithEmail(
      String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null && context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      _setLoading(false);
    }
  }
}
