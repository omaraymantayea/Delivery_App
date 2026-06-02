import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminDashboardTab extends StatelessWidget {
  final Function(
      {required String title,
      required String hint,
      required String dbPath,
      bool isMap,
      String? secondHint}) openDialog;
  const AdminDashboardTab({super.key, required this.openDialog});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabase.instance.ref();
    const accent = Color(0xFF818CF8);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('أداء المنظومة الحي اليوم',
              style: TextStyle(
                  color: accent, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              StreamBuilder(
                stream: db.child('admin_stats/total_commissions').onValue,
                builder: (context, snap) => _buildStatCard(
                    'إجمالي العمولات',
                    '${snap.data?.snapshot.value ?? '0'} EGP',
                    Icons.account_balance_wallet_rounded,
                    const Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              StreamBuilder(
                stream: db
                    .child('drivers')
                    .orderByChild('isOnline')
                    .equalTo(true)
                    .onValue,
                builder: (context, snap) => _buildStatCard(
                    'المناديب الأونلاين',
                    '${snap.data?.snapshot.value != null ? (snap.data!.snapshot.value as Map).length : 0} كابتن',
                    Icons.motorcycle_rounded,
                    Colors.amberAccent),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text('أدوات الإدارة السريعة',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildActionTile(
                  Icons.notifications_active_rounded,
                  'بث إشعار عام',
                  'إرسال تنبيه لكل التطبيق',
                  accent,
                  () => openDialog(
                      title: 'بث إشعار عام للمنظومة',
                      hint: 'اكتب نص التنبيه هنا...',
                      dbPath: 'broadcasts')),

              // العداد الحي للطلبات النشطة يقرأ ديناميكياً من الفايربيس 👇
              StreamBuilder(
                stream: db.child('orders').onValue,
                builder: (context, snap) {
                  int activeOrdersCount = 0;
                  if (snap.hasData && snap.data!.snapshot.value != null) {
                    Map orders = snap.data!.snapshot.value as Map;
                    // بنعد فقط الأوردرات اللي حالتها مش منتهية ولا ملغية
                    activeOrdersCount = orders.values
                        .where((order) =>
                            order['status'] != 'completed' &&
                            order['status'] != 'canceled')
                        .length;
                  }
                  return _buildActionTile(
                      Icons.view_list_rounded,
                      'الطلبات النشطة',
                      'مراقبة $activeOrdersCount رحلة الآن',
                      accent, () {
                    // هنا لما تضغط يفتح شاشة تفاصيل الأوردرات الحية أو الخريطة مستقبلاً
                  });
                },
              ),

              _buildActionTile(
                  Icons.no_accounts_rounded,
                  'القائمة السوداء',
                  'حظر مستخدمين أو مناديب',
                  Colors.redAccent,
                  () => openDialog(
                      title: 'إضافة رقم للقائمة السوداء',
                      hint: 'رقم الهاتف للحظر...',
                      dbPath: 'blacklist')),
              _buildActionTile(
                  Icons.local_offer_rounded,
                  'كوبونات الخصم',
                  'توليد وإدارة العروض',
                  Colors.cyanAccent,
                  () => openDialog(
                      title: 'توليد كوبون جديد',
                      hint: 'كود الكوبون (مثال: SMART20)',
                      secondHint: 'نسبة الخصم %',
                      dbPath: 'coupons',
                      isMap: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
          String title, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
      );

  Widget _buildActionTile(IconData icon, String title, String subtitle,
          Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 10)),
              ]),
        ),
      );
}
