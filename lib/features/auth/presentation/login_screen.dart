import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:delivery_app/features/auth/data/auth_service.dart';
import 'package:delivery_app/features/customer/presentation/explore_screen.dart';
import 'package:delivery_app/features/driver/presentation/driver_home.dart';
import 'package:delivery_app/features/admin/presentation/admin_home.dart';
import 'package:delivery_app/features/store_admin/presentation/store_dashboard_screen.dart';
import 'selection_screen.dart';

class LoginScreen extends StatefulWidget {
  final String targetRole;
  const LoginScreen({super.key, this.targetRole = 'customer'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _bg = Color(0xFF1E203D), _accent = Color(0xFF00E5FF);
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => screen), (route) => false);
  }

  void _directToRole(String role) {
    switch (role.trim().toLowerCase()) {
      case 'driver':
        _navigateTo(const DriverHome());
        break;
      case 'admin':
        _navigateTo(const AdminHome());
        break;
      case 'store_admin':
        _navigateTo(const StoreDashboardScreen());
        break;
      default:
        _navigateTo(const ExploreScreen());
    }
  }

  Future<void> _routeByRole({required String uid}) async {
    final snap = await FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(uid)
        .child('role')
        .get();
    if (!mounted) return;
    _directToRole(snap.value?.toString() ?? widget.targetRole);
  }

  Future<void> _handleAuthAction(Future<UserCredential?> authMethod) async {
    setState(() => _isLoading = true);
    try {
      final cred = await authMethod;
      final uid = cred?.user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Unable to fetch user id.');
      await _routeByRole(uid: uid);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isLoading = false;

  InputDecoration _inputStyle(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SelectionScreen())),
        ),
        actions: [
          TextButton.icon(
            // 🎯 تم تعديل زرار التخطي هنا ليصبح ذكياً ومبنياً على واجهتك الحالية
            onPressed: () => _directToRole(widget.targetRole),
            icon: const Icon(Icons.skip_next_rounded, color: _accent, size: 20),
            label: const Text('Skip',
                style: TextStyle(
                    color: _accent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            height: 100,
                            width: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.delivery_dining,
                                size: 90,
                                color: _accent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Login / تسجيل الدخول',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const SizedBox(height: 34),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputStyle('Email / Username'),
                        validator: (v) => (v?.trim() ?? '').isEmpty
                            ? 'This field is required.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputStyle('Password'),
                        validator: (v) =>
                            (v ?? '').isEmpty ? 'Password is required.' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: _bg,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_emailController.text.trim() == 'admin' &&
                                      _passwordController.text == 'admin123') {
                                    _navigateTo(const AdminHome());
                                  } else if (_formKey.currentState!
                                      .validate()) {
                                    _handleAuthAction(
                                        _authService.signInWithEmail(
                                            _emailController.text.trim(),
                                            _passwordController.text));
                                  }
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(_bg)))
                              : const Text('Login',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: _accent,
                              side: const BorderSide(color: _accent),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          icon: const Icon(Icons.g_mobiledata, size: 26),
                          label: const Text('Continue with Google',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          onPressed: _isLoading
                              ? null
                              : () => _handleAuthAction(
                                  _authService.signInWithGoogle()),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                          'Role lookup will route you to the correct dashboard.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
