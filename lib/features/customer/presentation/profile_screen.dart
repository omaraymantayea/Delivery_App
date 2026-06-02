import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delivery_app/core/routes/app_routes.dart';
import 'profile_detail_screen.dart';
// 🎯 التعديل الصح بناءً على مكان الملف تحت الـ driver presentation:
import 'package:delivery_app/features/driver/presentation/delivery_status_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF1E203D),
        surface = Color(0xFF14162E),
        accent = Color(0xFF00E5FF);
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'User';

    Widget profileOption({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color textColor = Colors.white,
      Color iconColor = accent,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.03))),
          child: ListTile(
            onTap: onTap,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            title: Text(title,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            subtitle: Text(subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white24, size: 14),
          ),
        ),
      );
    }

    void navigateToDetail(String title, String type) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProfileDetailScreen(title: title, type: type)));
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text('My Profile / الحساب الشخصي',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withOpacity(0.1))),
            child: Column(
              children: [
                CircleAvatar(
                    radius: 40,
                    backgroundColor: accent.withOpacity(0.1),
                    child: const Icon(Icons.person_rounded,
                        color: accent, size: 45)),
                const SizedBox(height: 12),
                Text(displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.email ?? 'No email found',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _sectionHeader('My Activity / نشاطي', accent),
          profileOption(
            icon: Icons.receipt_long_rounded,
            title: 'Order Summary / ملخص الطلب الحالي',
            subtitle: 'تتبع تفاصيل وفاتورة طلبك الأخير المفتوح',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DeliveryStatusScreen()));
            },
          ),
          profileOption(
            icon: Icons.shopping_bag_outlined,
            title: 'Checkout Screen / شاشة الدفع والطلب',
            subtitle: 'انتقل لمراجعة السلة وإتمام الدفع',
            onTap: () => Navigator.pushNamed(context, AppRoutes.checkout),
          ),
          const SizedBox(height: 15),
          _sectionHeader('Account Settings / إعدادات الحساب', accent),
          profileOption(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information / البيانات الشخصية',
            subtitle: 'تعديل الاسم، رقم الهاتف، والبريد الإلكتروني',
            onTap: () => navigateToDetail('البيانات الشخصية', 'info'),
          ),
          profileOption(
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses / العناوين المسجلة',
            subtitle: 'إدارة مواقع التوصيل والمنزل والعمل',
            onTap: () => navigateToDetail('العناوين المسجلة', 'addresses'),
          ),
          profileOption(
            icon: Icons.settings_outlined,
            title: 'Settings / الإعدادات العامة',
            subtitle: 'اللغة، الإشعارات، ووضع التطبيق',
            onTap: () => navigateToDetail('الإعدادات العامة', 'settings'),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          profileOption(
            icon: Icons.logout_rounded,
            title: 'Logout / تسجيل الخروج',
            subtitle: 'الخروج بأمان والعودة لشاشة تحديد الأدوار',
            textColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.selection, (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(text,
          style: TextStyle(
              color: accent, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}
