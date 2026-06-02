import 'dart:async';
import 'package:flutter/material.dart';
import 'selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SelectionScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backColor = Color(0xFF1E203D); // كحلي اللوجو
    const accentColor = Color(0xFF00E5FF); // لبني اللوجو النيون

    return Scaffold(
      backgroundColor: backColor,
      body: Container(
        // 🚀 الفريم اللبني النيون المحيط بالشاشة بالكامل
        margin: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          color: backColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.6), // 🌟 تم التحديث لتجنب الـ deprecation
            width: 2.5, 
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15), // 🌟 تم التحديث لتجنب الـ deprecation
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Stack(
          children: [
            // 🎯 اللوجو والـ Indicator في منتصف الشاشة مع الأنميشن
            Center(
              child: FadeTransition(
                opacity: _animation,
                child: ScaleTransition(
                  scale: _animation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.jpeg',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.delivery_dining_rounded,
                            size: 120,
                            color: accentColor,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(
                        width: 60,
                        child: LinearProgressIndicator(
                          color: accentColor,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✨ حقوق التصميم والبرمجة بالإنجليزية أسفل الشاشة (تم إصلاح الكود هنا بالملي)
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.0), // 🛠️ الحل الصحيح للأيرور
                child: Text(
                  'Programmed & Designed by Omar Ayman',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}