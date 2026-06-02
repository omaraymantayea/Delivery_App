import 'package:flutter/material.dart';
import 'package:delivery_app/core/routes/app_routes.dart';

// 📥 الـ Imports بالـ Clean Architecture الصحيحة بناءً على مسار ملفاتك الفعلي
import 'widgets/driver_orders_screen.dart'; // 🔥 تم التعديل للمسار الصحيح جوه فولدر widgets
import 'delivery_status_screen.dart'; 
import 'widgets/driver_profile_tab.dart';
import 'widgets/driver_gps_tracking_tab.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  int _currentIndex = 0;
  bool _isOnline = true;
  
  late final List<Widget> _driverScreens = [
    DriverOrdersScreen(isOnline: () => _isOnline),
    const DeliveryStatusScreen(),
    const DriverProfileTab(),
    const DriverGpsTrackingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const driverAccent = Color(0xFFFFB300);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentIndex == 0) {
          Navigator.pushReplacementNamed(context, AppRoutes.selection);
        } else {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E203D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF14162E),
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.selection),
          ),
          title: Row(
            children: [
              CircleAvatar(backgroundColor: _isOnline ? Colors.green : Colors.red, radius: 5),
              const SizedBox(width: 8),
              Text(_isOnline ? 'كابتن متصل | أونلاين' : 'كابتن غير متصل | أوفلاين', 
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            Switch(
              value: _isOnline,
              activeThumbColor: driverAccent,
              activeTrackColor: driverAccent.withValues(alpha: 0.4),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.white12,
              onChanged: (value) => setState(() => _isOnline = value),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: IndexedStack(index: _currentIndex, children: _driverScreens),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF14162E),
          selectedItemColor: driverAccent,
          unselectedItemColor: Colors.white38,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 15,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping_rounded), label: 'سوق الطلبات'),
            BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'الطلب النشط'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'المحفظة والحساب'),
            BottomNavigationBarItem(icon: Icon(Icons.location_on_rounded), label: 'تتبع الـ GPS'),
          ],
        ),
      ),
    );
  }
}