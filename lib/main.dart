import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // مكتبة معرفة نوع المنصة
import 'package:firebase_core/firebase_core.dart';
import 'package:delivery_app/core/routes/app_routes.dart';
import 'package:delivery_app/core/routes/route_manager.dart';

// 🔥 الـ Notifier السحري اللي هيتحكم في ثيم الأبليكيشن كله لايف (يبدأ بالداكن)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الفايربيز للموبايل فقط، وتخطيه في الويب لمنع الصفحة البيضاء
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 لفينا الـ MaterialApp بـ ValueListenableBuilder عشان يسمع في كل شاشات الأبليكيشن فوراً
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Smart Delivery App',
          debugShowCheckedModeBanner: false,
          
          themeMode: currentMode, // 🌟 يحدد المود الحالي (Light أو Dark)

          // ☀️ ثيم الـ Light Mode المتناسق مع الألوان الأساسية
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC), // خلفية بيضاء مريحة ونظيفة
            primaryColor: const Color(0xFFFFB300),
            dividerColor: Colors.black12,
          ),
          
          // 🌙 ثيم الـ Dark Mode الأصلي بتاعك المريح للعين
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1E203D), // خلفيتك الداكنة المفضلة
            primaryColor: const Color(0xFFFFB300),
            dividerColor: Colors.white10,
          ),

          initialRoute: AppRoutes.splash,
          onGenerateRoute: const RouteManager().onGenerateRoute,
        );
      },
    );
  }
}