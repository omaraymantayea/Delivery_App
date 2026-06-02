import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String title; // عنوان الصفحة (مثلاً: المعلومات الشخصية)
  final String type; // نوع الصفحة (info, addresses, payment, settings)

  const ProfileDetailScreen(
      {super.key, required this.title, required this.type});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();

  // Controllers للخلايا
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // جلب البيانات الحقيقية للعميل من الفايربيس لو موجودة
  void _loadUserData() async {
    if (_uid == null) return;
    setState(() => _isLoading = true);

    final snap = await _db.child('users').child(_uid!).child('profile').get();
    if (snap.exists && mounted) {
      final data = snap.value as Map;
      _nameCtrl.text = data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _addressCtrl.text = data['address'] ?? '';
      _notesCtrl.text = data['notes'] ?? '';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // حفظ البيانات الجديدة في الفايربيس نضافة
  void _saveData() async {
    if (_uid == null) return;
    setState(() => _isLoading = true);

    await _db.child('users').child(_uid!).child('profile').update({
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'lastUpdated': ServerValue.timestamp,
    });

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('تم حفظ البيانات بنجاح ✅'),
            backgroundColor: Color(0xFF00E5FF)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0B121F);
    const Color fill = Color(0xFF1E203D);
    const Color accent = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // الشاشة بتعرض الحقول ديناميكياً بناءً على الزرار اللي اتداس عليه
                    if (widget.type == 'info') ...[
                      _buildTextField(
                          _nameCtrl, 'الاسم بالكامل / Full Name', Icons.person),
                      const SizedBox(height: 14),
                      _buildTextField(
                          _phoneCtrl, 'رقم الهاتف / Phone Number', Icons.phone,
                          isPhone: true),
                    ],
                    if (widget.type == 'addresses') ...[
                      _buildTextField(
                          _addressCtrl,
                          'العنوان بالتفصيل / Detailed Address',
                          Icons.location_on),
                      const SizedBox(height: 14),
                      _buildTextField(_notesCtrl,
                          'ملاحظات التوصيل (مثلا الدور/الشقة)', Icons.comment),
                    ],
                    if (widget.type == 'payment') ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: fill,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Column(
                          children: [
                            Icon(Icons.credit_card, color: accent, size: 40),
                            SizedBox(height: 12),
                            Text('طرق الدفع المفعلة',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(
                                'الدفع نقداً عند الاستلام (COD)\nالمحافظ الإلكترونية الرقمية',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 13)),
                          ],
                        ),
                      )
                    ],
                    if (widget.type == 'settings') ...[
                      _buildSettingsTile(
                          'لغة التطبيق / Language', 'العربية', Icons.language),
                      _buildSettingsTile('الوضع الداكن / Dark Mode',
                          'مفعل تلقائياً', Icons.dark_mode),
                      _buildSettingsTile('الدعم الفني / Support', 'تواصل معنا',
                          Icons.headset_mic),
                    ],
                    const SizedBox(height: 24),
                    if (widget.type == 'info' || widget.type == 'addresses')
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: bg,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _saveData,
                          child: const Text('حفظ التغييرات',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon,
      {bool isPhone = false}) {
    return TextFormField(
      controller: ctrl,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        suffixIcon: Icon(icon, color: const Color(0xFF00E5FF)),
        filled: true,
        fillColor: const Color(0xFF1E203D),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E5FF))),
      ),
    );
  }

  Widget _buildSettingsTile(String title, String trailing, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF1E203D),
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(trailing,
            style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13)),
        title: Text(title,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Icon(icon, color: Colors.white54),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}
