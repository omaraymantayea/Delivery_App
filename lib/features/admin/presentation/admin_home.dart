import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:delivery_app/core/routes/app_routes.dart';

import 'package:delivery_app/features/admin/presentation/admin_dashboard_tab.dart';
import 'package:delivery_app/features/admin/presentation/admin_stores_tab.dart';
import 'package:delivery_app/features/admin/presentation/admin_settings_tab.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;
  final _db = FirebaseDatabase.instance.ref();

  void _openAdminDialog({
    required String title,
    required String hint,
    required String dbPath,
    bool isMap = false,
    String? secondHint,
  }) {
    final input1 = TextEditingController();
    final input2 = TextEditingController();

    // معرفة حالة الثيم الحالي أثناء فتح الـ Dialog
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // 🔥 يتغير لون الخلفية أوتوماتيكياً بناءً على المود
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          title,
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: input1,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: isDark ? Colors.white30 : Colors.black12),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF818CF8)),
                ),
              ),
            ),
            if (secondHint != null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: input2,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: secondHint,
                  hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: isDark ? Colors.white30 : Colors.black12),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF818CF8)),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء',
                style:
                    TextStyle(color: isDark ? Colors.white60 : Colors.black45)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF818CF8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (input1.text.trim().isEmpty) return;

              if (isMap && input2.text.isNotEmpty) {
                await _db.child(dbPath).set({
                  'value': input1.text.trim(),
                  'discount': int.tryParse(input2.text.trim()) ?? 0,
                  'active': true,
                });
              } else {
                await _db.child(dbPath).push().set(input1.text.trim());
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              'تأكيد',
              style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> adminScreens = [
      AdminDashboardTab(openDialog: _openAdminDialog),
      const AdminStoresTab(),
      AdminSettingsTab(openDialog: _openAdminDialog),
    ];

    // دبابيس الألوان الديناميكية المستوحاة من الـ Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final appBarIconColor = isDark ? Colors.white70 : Colors.black54;
    final appBarTitleColor = isDark ? Colors.white : Colors.black87;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, AppRoutes.selection);
        }
      },
      child: Scaffold(
        // 🔥 يسحب لون الخلفية الأساسية من الـ MaterialApp أوتوماتيكياً
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: navBgColor,
          elevation: isDark ? 2 : 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: appBarIconColor, size: 18),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.selection),
          ),
          title: Text(
            _currentIndex == 0
                ? 'غرفة التحكم العليا'
                : _currentIndex == 1
                    ? 'طلبات الانضمام المعلقة'
                    : 'إعدادات النظام العليا',
            style: TextStyle(
                color: appBarTitleColor,
                fontWeight: FontWeight.w900,
                fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: IndexedStack(index: _currentIndex, children: adminScreens),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: navBgColor,
          selectedItemColor: const Color(0xFF818CF8),
          unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'الرئيسية والتحليلات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'إدارة المتاجر',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_rounded),
              label: 'التحكم العام',
            ),
          ],
        ),
      ),
    );
  }
}
