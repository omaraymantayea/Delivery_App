import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'restaurants'; // القسم الافتراضي
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('لم يتم العثور على تسجيل دخول للمتجر');

      // الداتا اللي هتترفع على الفايربيس
      final productData = {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'storeId': user.uid, // ربط الوجبة بـ ID المتجر الحالي
        'createdAt': ServerValue.timestamp,
      };

      // 1. هنضيف الوجبة في جدول المنتجات العام تحت القسم بتاعها عشان العميل يشوفها
      final newProductRef = FirebaseDatabase.instance
          .ref()
          .child('products')
          .child(_selectedCategory)
          .push();

      await newProductRef.set(productData);

      // 2. هنضيف نفس الوجبة تحت منيو المتجر نفسه عشان تظهر له في لوحة التحكم
      await FirebaseDatabase.instance
          .ref()
          .child('stores')
          .child(user.uid)
          .child('menu')
          .child(newProductRef.key!)
          .set(productData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إضافة الوجبة بنجاح ونشرها للعملاء! 🎉')),
        );
        Navigator.pop(context); // الرجوع للوحة التحكم
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء الحفظ: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B121F);
    const cardBg = Color(0xFF1E203D);
    const accent = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('إضافة وجبة / منتج جديد',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // حقل اسم الوجبة
                _buildTextField(_nameController, 'اسم الوجبة / المنتج',
                    Icons.fastfood, cardBg, accent),
                const SizedBox(height: 16),

                // حقل السعر
                _buildTextField(_priceController, 'السعر (EGP)',
                    Icons.attach_money, cardBg, accent,
                    isNumber: true),
                const SizedBox(height: 16),

                // حقل الوصف
                _buildTextField(_descController, 'وصف الوجبة ومكوناتها',
                    Icons.description, cardBg, accent,
                    maxLines: 3),
                const SizedBox(height: 16),

                // اختيار القسم (Dropdown)
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: cardBg,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'تصنيف القسم الحالي',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.category, color: accent),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'restaurants',
                        child: Text('مطاعم / Restaurants')),
                    DropdownMenuItem(
                        value: 'groceries',
                        child: Text('سوبرماركت / Groceries')),
                    DropdownMenuItem(
                        value: 'pharmacies', child: Text('صيدلية / Pharmacy')),
                    DropdownMenuItem(
                        value: 'gifts', child: Text('هدايا / Gifts')),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedCategory = v ?? 'restaurants'),
                ),
                const SizedBox(height: 32),

                // زرار الحفظ الـ Active
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: bg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(bg)))
                        : const Text('حفظ ونشر الوجبة بالفور',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      IconData icon, Color fill, Color accent,
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: accent),
        filled: true,
        fillColor: fill,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accent, width: 1.5)),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }
}
