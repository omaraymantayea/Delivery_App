import 'package:flutter/material.dart';

class LiveOrdersList extends StatelessWidget {
  const LiveOrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2, 
      itemBuilder: (context, index) {
        List<String> orderIds = ['#ORD-9542', '#ORD-9543'];
        List<String> orderItems = ['2x بيج ماك كومبو + بطاطس حجم عائلي', '1x بيتزا رانش حجم كبير + لتر كولا'];
        List<String> orderStatus = ['جاري التحضير 🍳', 'الأكل جاهز 📦'];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937), 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(orderIds[index], style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                    child: Text(orderStatus[index], style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(color: Colors.white10),
              ),
              Text(orderItems[index], style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), 
                        foregroundColor: Colors.black, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {},
                      child: const Text('تحديث الحالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ⚡ زرار استدعاء طيار عاجل (Ping Driver) السحري
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.amber.withOpacity(0.1), 
                      side: const BorderSide(color: Colors.amber), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚡ جاري إرسال إشعار استعجال قوي لهاتف الكابتن المسؤول عن التوصيل!'),
                          backgroundColor: Colors.amber,
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}