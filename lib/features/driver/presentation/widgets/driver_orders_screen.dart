import 'package:flutter/material.dart';

class DriverOrdersScreen extends StatelessWidget {
  final ValueGetter<bool> isOnline;
  const DriverOrdersScreen({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    if (!isOnline()) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.power_settings_new_rounded, size: 70, color: Colors.white24),
            SizedBox(height: 16),
            Text('أنت في وضع عدم الاتصال الآن', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('قم بتفعيل زر الاتصال بالأعلى لبدء استقبال الطلبات', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, idx) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF14162E), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✨ تم الإصلاح الحاسم هنا
                children: [
                  Text('طلب توصيل جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('35 EGP', style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(color: Colors.white10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB300)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Color(0xFFFFB300), content: Text('تم قبول الطلب بنجاح وجاري فتح الخريطة...', style: TextStyle(color: Color(0xFF1E203D), fontWeight: FontWeight.bold))),
                  );
                },
                child: const Text('قبول الطلب', style: TextStyle(color: Color(0xFF1E203D), fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}