import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'store_dashboard_screen.dart';

class PartnerRegistrationScreen extends StatefulWidget {
  const PartnerRegistrationScreen({super.key});

  @override
  State<PartnerRegistrationScreen> createState() => _PartnerRegistrationScreenState();
}

class _PartnerRegistrationScreenState extends State<PartnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); 
  final _passwordCtrl = TextEditingController(); 

  String _selectedCategory = 'restaurants'; 
  String _selectedPayment = 'Digital Wallet';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); 
    _addressCtrl.dispose(); 
    _taxCtrl.dispose();
    _emailCtrl.dispose(); 
    _passwordCtrl.dispose();
    super.dispose();
  }

  // 🆔 بوب أب احترافي يعرض الـ ID الفريد للتاجر فوراً بعد الضغط على Setup
  void _showIdDialog(String storeId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E203D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تم تسجيل متجرك بنجاح! 🎉', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('انسخ الـ Store ID الخاص بك لاستخدامه لاحقاً:', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B121F), 
                borderRadius: BorderRadius.circular(10), 
                border: Border.all(color: const Color(0xFF00E5FF), width: 1),
              ),
              child: SelectableText(
                storeId,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF), 
                foregroundColor: const Color(0xFF0B121F), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context); // إغلاق البوب أب
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (_) => const StoreDashboardScreen()),
                );
              },
              child: const Text('الانتقال للوحة التحكم', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. إنشاء الحساب في Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(), 
        password: _passwordCtrl.text.trim(),
      );

      final String? uid = userCredential.user?.uid;

      if (uid != null) {
        // 2. حفظ البيانات بالـ UID كمفتاح فريد للمتجر
        await FirebaseDatabase.instance.ref().child('stores').child(uid).set({
          'storeId': uid,
          'businessName': _nameCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'taxId': _taxCtrl.text.trim(),
          'category': _selectedCategory, 
          'paymentMethod': _selectedPayment,
          'email': _emailCtrl.text.trim(),
          'createdAt': ServerValue.timestamp,
        });

        if (mounted) {
          _showIdDialog(uid); // تشغيل البوب أب
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التسجيل: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B121F), fill = Color(0xFF1E203D), accent = Color(0xFF00E5FF);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, foregroundColor: Colors.white, 
        title: const Text('Partner Registration', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('1. Business Info', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                _input(_nameCtrl, 'Name', Icons.store, fill, accent),
                const SizedBox(height: 12),
                _input(_addressCtrl, 'Address', Icons.location_on, fill, accent),
                const SizedBox(height: 12),
                _input(_taxCtrl, 'Tax ID', Icons.assignment, fill, accent),
                
                const SizedBox(height: 20),
                const Text('2. Account Access', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                _input(_emailCtrl, 'Email Address', Icons.email, fill, accent),
                const SizedBox(height: 12),
                _input(_passwordCtrl, 'Password', Icons.lock, fill, accent, isSecure: true),
                
                const SizedBox(height: 20),
                const Text('3. Menu/Inventory Setup', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                _dropdown([
                  {'label': 'مطاعم / Restaurants', 'value': 'restaurants'},
                  {'label': 'سوبرماركت / Groceries', 'value': 'groceries'},
                  {'label': 'صيدلية / Pharmacy', 'value': 'pharmacy'},
                ], _selectedCategory, 'Categories', fill, accent, (v) => setState(() => _selectedCategory = v!)),
                
                const SizedBox(height: 20),
                const Text('4. Setup Payment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                _dropdown([
                  {'label': 'Digital Wallet', 'value': 'Digital Wallet'}, 
                  {'label': 'Bank Account', 'value': 'Bank Account'},
                ], _selectedPayment, 'Payment Method', fill, accent, (v) => setState(() => _selectedPayment = v!)),
                
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: bg) 
                      : const Text('Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint, IconData icon, Color fill, Color accent, {bool isSecure = false}) {
    return TextFormField(
      controller: ctrl, obscureText: isSecure, style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Colors.white38), prefixIcon: Icon(icon, color: accent),
        filled: true, fillColor: fill,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent.withOpacity(0.4))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent, width: 1.5)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null,
    );
  }

  Widget _dropdown(List<Map<String, String>> items, String value, String label, Color fill, Color accent, ValueChanged<String?>? onChange) {
    return DropdownButtonFormField<String>(
      initialValue: value, dropdownColor: fill,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70), filled: true, fillColor: fill, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: accent.withOpacity(0.4)))),
      items: items.map((e) => DropdownMenuItem(value: e['value'], child: Text(e['label']!, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: onChange,
    );
  }
}