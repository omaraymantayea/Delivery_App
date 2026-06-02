import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delivery_app/core/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSettingsTab extends StatelessWidget {
  final Function({required String title, required String hint, required String dbPath, bool isMap, String? secondHint}) openDialog;
  const AdminSettingsTab({super.key, required this.openDialog});

  // 📞 دالة فتح الواتساب الخاصة بالدعم الفني
  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/201014477627");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF818CF8);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🌟 زرار صلاحيات المشرفين
            _buildOption(
              Icons.security_rounded, 
              'صلاحيات المشرفين', 
              'إضافة أو سحب رتبة أدمن مساعد وترقية الحسابات', 
              accent, 
              () {
                openDialog(
                  title: 'صلاحيات وتعيين المشرفين', 
                  hint: 'اكتب البريد الإلكتروني للمشرف أو معرف الحساب...', 
                  dbPath: 'admin_stats/admin_permissions'
                );
              },
            ),

            // 💵 زرار نسبة عمولة التطبيق
            _buildOption(
              Icons.monetization_on_rounded, 
              'نسبة عمولة التطبيق', 
              'تعديل النسبة الحالية (أوتوماتيك 15%)', 
              accent, 
              () {
                openDialog(
                  title: 'تعديل نسبة عمولة التطبيق', 
                  hint: 'اكتب النسبة الجديدة هنا...', 
                  dbPath: 'admin_stats/commission_rate'
                );
              },
            ),

            // 🌟 زرار الشروط والقوانين
            _buildOption(
              Icons.gavel_rounded, 
              'الشروط والقوانين', 
              'تحديث سياسات الخصوصية والعمل للشركاء والكباتن', 
              accent, 
              () {
                openDialog(
                  title: 'تحديث الشروط والقوانين', 
                  hint: 'اكتب السياسات أو الشروط الجديدة هنا...', 
                  dbPath: 'admin_stats/terms_and_conditions'
                );
              },
            ),

            const Divider(color: Colors.white10, height: 30),

            // 🆕 حقل التواصل مع الدعم الفني (WhatsApp)
            _buildOption(
              Icons.support_agent_rounded, 
              'تواصل مع الدعم الفني', 
              'الدعم الفني المباشر لحل مشاكل لوحة التحكم والتطبيق', 
              Colors.greenAccent, 
              _launchWhatsApp,
            ),

            const SizedBox(height: 20),

            // 🚪 زر تسجيل الخروج
            ListTile(
              tileColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('تسجيل خروج المشرف الهام', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('غلق جلسة التحكم الحالية والعودة للخلف', style: TextStyle(color: Colors.white38, fontSize: 10)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.selection, (route) => false);
              },
            ),

            const SizedBox(height: 100), // مساحة أمان للحقوق اللي تحت لضمان عدم التداخل
          ],
        ),

        // ✨ برمجة وتصميم عمر أيمن - متصلحة تماماً ومستحيل تضرب أيرور كونسنت
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0), // 👈 اتصلحت هنا
            child: Text(
              'Programmed & Designed by Omar Ayman',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      leading: Icon(icon, color: color), 
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
      onTap: onTap,
    ),
  );
}