import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';
import 'splash_screen.dart';
import '../../store_admin/presentation/partner_registration_screen.dart';
// 🔥 استيراد الـ Notifier السحري من الـ main عشان نتحكم في المود
import 'package:delivery_app/main.dart'; 

class RoleModel {
  final String role, title;
  final IconData icon;
  const RoleModel({required this.role, required this.title, required this.icon});
}

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});
  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  // 🎨 الألوان الأساسية: شيلنا لون الخلفية الثابت وخلينا الـ Accent مرن ومتناسق
  static const _accent = Color(0xFF00E5FF);
  String? _selectedRole;

  final List<RoleModel> _rolesList = const [
    RoleModel(
        role: 'customer',
        title: 'Customer\nالعميل',
        icon: Icons.local_mall_rounded),
    RoleModel(
        role: 'driver',
        title: 'Delivery Captain\nكابتن التوصيل',
        icon: Icons.delivery_dining_rounded),
    RoleModel(
        role: 'store_admin',
        title: 'Store Partner\nشريك المتجر',
        icon: Icons.storefront_rounded),
    RoleModel(
        role: 'admin',
        title: 'Admin\nالأدمن / المدير',
        icon: Icons.admin_panel_settings_rounded),
  ];

  Future<void> _continue() async {
    final role = _selectedRole;
    if (role == null) return;

    if (!kIsWeb) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseDatabase.instance.ref('users/$uid/role').set(role);
      }
    }
    if (!mounted) return;

    if (role == 'store_admin') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PartnerRegistrationScreen()),
          (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen(targetRole: role)),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 فحص حالة المود الحالي (هل هو داكن أم مضيء؟)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // تحديد ألوان النصوص والأيقونات لتتغير ديناميكياً مع المود
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black54;
    final cardBgColor = isDark ? const Color(0xFF1E203D) : Colors.white;

    return Scaffold(
      // 🔥 يقفل اللون الثابت ويأخذ الخلفية أوتوماتيك من الثيم الرئيسي
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const SplashScreen())),
        ),
        actions: [
          // ☀️🌙 الزرار السحري الموحد للتحكم في ثيم الأبليكيشن بالكامل من شاشة السيلكشن
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? const Color(0xFFFFB300) : const Color(0xFF14162E),
            ),
            onPressed: () {
              // يقلب المود في الـ main لحظياً ويحدث الشاشة الحالية وكل الشاشات اللي هتنزل بعد كدة
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text('Smart Delivery',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    fontSize: 26,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text('Choose your role to log in / اختيار الدور',
                style: TextStyle(color: subTextColor, fontSize: 14)),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 340,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rolesList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.0),
                    itemBuilder: (context, index) {
                      final item = _rolesList[index];
                      final isSelected = _selectedRole == item.role;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRole = item.role),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            // 🔥 لون الكارت يتغير حسب المود (أبيض في اللايت، وداكن في الدارك)
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? _accent
                                    : _accent.withValues(alpha: 0.25),
                                width: isSelected ? 2.5 : 1.2),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color: _accent.withValues(alpha: 0.2),
                                        blurRadius: 12,
                                        spreadRadius: 1)
                                  ]
                                : !isDark 
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)] 
                                    : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(item.icon,
                                  color: isSelected ? _accent : (isDark ? Colors.white70 : Colors.black54),
                                  size: 32),
                              const SizedBox(height: 12),
                              Text(item.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedRole == null ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: const Color(0xFF1E203D),
                    disabledBackgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: const Text('Continue / متابعة',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}