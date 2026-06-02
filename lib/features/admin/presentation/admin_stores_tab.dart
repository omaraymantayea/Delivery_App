import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminStoresTab extends StatelessWidget {
  const AdminStoresTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabase.instance.ref();
    return StreamBuilder(
      stream: db.child('store_joining_requests').onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('لا توجد طلبات انضمام معلقة حالياً', style: TextStyle(color: Colors.white38)));
        }
        Map requests = snapshot.data!.snapshot.value as Map;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: requests.entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.storefront_rounded, color: Color(0xFF818CF8), size: 26)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value['storeName'] ?? 'متجر جديد', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(e.value['storeType'] ?? 'مأكولات', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ])),
              Row(children: [
                IconButton(icon: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent), onPressed: () async {
                  await db.child('approved_stores/${e.key}').set(e.value);
                  await db.child('store_joining_requests/${e.key}').remove();
                }),
                IconButton(icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent), onPressed: () async => await db.child('store_joining_requests/${e.key}').remove()),
              ])
            ]),
          )).toList(),
        );
      },
    );
  }
}