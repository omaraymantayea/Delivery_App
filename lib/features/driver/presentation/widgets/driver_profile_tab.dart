import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_app/core/routes/app_routes.dart';

class DriverProfileTab extends StatelessWidget {
  const DriverProfileTab({super.key});

  void _showDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF14162E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(color: Color(0xFFFFB300), fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
        content: Text(msg, style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.right),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق', style: TextStyle(color: Colors.white38)))],
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/201014477627");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const driverAccent = Color(0xFFFFB300);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF14162E), borderRadius: BorderRadius.circular(20), border: Border.all(color: driverAccent.withValues(alpha: 0.15), width: 1.5)),
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: driverAccent.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.monetization_on_rounded, color: driverAccent, size: 35)),
              const SizedBox(height: 12),
              const Text('إجمالي رصيدك الحالي جاهز للسحب', style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 6),
              const Text('720.00 EGP', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: driverAccent, minimumSize: const Size(double.infinity, 42), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF1E203D), size: 18),
                label: const Text('طلب سحب الأرباح كاش', style: TextStyle(color: Color(0xFF1E203D), fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () => _showDialog(context, 'سحب الأرباح', 'جاري معالجة التحويل الفوري لحسابك عبر إنستا باي أو فودافون كاش... رصيدك الحالي 720.00 EGP.'),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildOpt(Icons.analytics_outlined, 'إحصائيات الأداء اليومي', 'عدد الساعات النشطة، والطلبات المسلمة اليوم', driverAccent, () => _showDialog(context, 'إحصائيات الأداء', 'اليوم: 4 ساعات نشطة\nالطلبات المسلمة: 5 طلبات\nتقييمك اليومي: 4.9 ⭐')),
        _buildOpt(Icons.history_toggle_off_rounded, 'سجل الرحلات المكتملة', 'مراجعة فواتير وبيانات الأوردرات السابقة', driverAccent, () => _showDialog(context, 'سجل الرحلات', 'طلب #2041 - تم التوصيل - 45 EGP\nطلب #2039 - تم التوصيل - 60 EGP')),
        _buildOpt(Icons.support_agent_rounded, 'تواصل مع الدعم الفني (Contact Support)', 'الدعم الفني المباشر لحل المشاكل الفنية فوراً', Colors.tealAccent, _launchWhatsApp),
        _buildOpt(Icons.chat_rounded, 'الخط الساخن للكباتن (واتساب)', 'تواصل سريع بخصوص تحصيل الكاش واللوكيشن', Colors.greenAccent, _launchWhatsApp),
        const Divider(color: Colors.white10, height: 30),
        _buildOpt(Icons.logout_rounded, 'تسجيل الخروج من حساب الكابتن', 'العودة بأمان لشاشة اختيار نوع الحساب الرئيسية', Colors.redAccent, () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.selection, (route) => false);
          }
        }, txtColor: Colors.redAccent),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'Programmed & Designed by Omar Ayman',
            style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildOpt(IconData icon, String title, String sub, Color color, VoidCallback onTap, {Color txtColor = Colors.white}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFF14162E), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 22)),
        title: Text(title, style: TextStyle(color: txtColor, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 13),
      ),
    );
  }
}