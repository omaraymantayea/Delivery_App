import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../admin/presentation/admin_home.dart';
import '../../customer/presentation/customer_home.dart';
import '../../driver/presentation/driver_home.dart';
import '../data/auth_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  static const _bg = Color(0xFF0B121F);
  static const _accent = Color(0xFF00E5FF);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String _role = 'customer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color _accentOpacity(double alpha) => _accent.withValues(alpha: alpha);

  Future<void> _routeByRole(String uid) async {
    final snap = await FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(uid)
        .child('role')
        .get();
    final role = snap.value?.toString().trim().toLowerCase() ?? '';
    if (!mounted) return;

    Widget nextScreen = const SizedBox.shrink();
    // 🎯 التعديل هنا: تم تعديل الكلاس لـ CustomerHomeScreen
    if (role == 'customer') nextScreen = const CustomerHomeScreen();
    if (role == 'driver') nextScreen = const DriverHome();
    if (role == 'admin') nextScreen = const AdminHome();
    if (role == 'store_admin') {
      Navigator.pushReplacementNamed(context, AppRoutes.customer);
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => nextScreen));
    }
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cred = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _role,
      );
      final uid = cred?.user?.uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Unable to fetch user id.');
      await _routeByRole(uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
          backgroundColor: _bg,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Sign Up / إنشاء حساب')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.person_add_alt_1_rounded,
                        size: 80, color: _accent),
                    const SizedBox(height: 12),
                    Text('Create your account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                    const SizedBox(height: 24),
                    _buildField(
                        _nameController, 'Full Name / الاسم بالكامل', false),
                    const SizedBox(height: 14),
                    _buildField(
                        _emailController, 'Email / البريد الإلكتروني', false,
                        isEmail: true),
                    const SizedBox(height: 14),
                    _buildField(
                        _passwordController, 'Password / كلمة المرور', true),
                    const SizedBox(height: 18),
                    _buildRoleDropdown(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUpWithEmail,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: _bg,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(_bg)))
                            : const Text('Sign Up',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, bool obscure,
      {bool isEmail = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: _accentOpacity(0.06),
        enabledBorder: _border(),
        focusedBorder: _border(focused: true),
      ),
      validator: (v) => (v == null || v.trim().isEmpty)
          ? 'Field is required.'
          : (isEmail && !v.contains('@') ? 'Enter a valid email.' : null),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _role,
      dropdownColor: _bg,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          filled: true,
          fillColor: _accentOpacity(0.05),
          enabledBorder: _border(),
          focusedBorder: _border(focused: true)),
      items: const [
        DropdownMenuItem(value: 'customer', child: Text('customer / عميل')),
        DropdownMenuItem(value: 'driver', child: Text('driver / سائق')),
        DropdownMenuItem(
            value: 'store_admin', child: Text('store_admin / مدير متجر')),
      ],
      onChanged: (v) => setState(() => _role = v ?? 'customer'),
    );
  }

  OutlineInputBorder _border({bool focused = false}) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: focused ? _accent : _accentOpacity(0.5),
            width: focused ? 2 : 1));
  }
}
