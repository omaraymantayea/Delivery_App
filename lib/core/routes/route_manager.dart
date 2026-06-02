import 'package:flutter/material.dart';
import 'package:delivery_app/features/auth/presentation/splash_screen.dart';
import '../../features/admin/presentation/admin_home.dart';
import '../../features/customer/presentation/customer_home.dart';
import '../../features/driver/presentation/driver_home.dart';
import '../../features/auth/presentation/login_screen.dart'; 
import 'app_routes.dart';

import '../../features/customer/presentation/explore_screen.dart';
import '../../features/customer/presentation/checkout_screen.dart';
import '../../features/store_admin/presentation/partner_registration_screen.dart';
import '../../features/store_admin/presentation/store_dashboard_screen.dart';
import '../../features/driver/presentation/delivery_status_screen.dart';

class RouteManager {
  const RouteManager();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login: 
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.customer:
        // 🎯 التعديل هنا: تم تغيير الاسم لـ CustomerHomeScreen ليطابق الكلاس عندك
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
      case AppRoutes.driver:
        return MaterialPageRoute(builder: (_) => const DriverHome());
      case AppRoutes.admin:
        return MaterialPageRoute(builder: (_) => const AdminHome());

      case AppRoutes.explore:
        return MaterialPageRoute(builder: (_) => const ExploreScreen());
      case AppRoutes.checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case AppRoutes.partnerRegistration:
        return MaterialPageRoute(builder: (_) => const PartnerRegistrationScreen());
      case AppRoutes.storeDashboard:
        return MaterialPageRoute(builder: (_) => const StoreDashboardScreen());
      case AppRoutes.deliveryStatus:
        return MaterialPageRoute(builder: (_) => const DeliveryStatusScreen());
        
      case AppRoutes.splash: 
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}