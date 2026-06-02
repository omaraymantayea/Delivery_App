import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CategoryProductsScreen extends StatefulWidget {
  // 🎯 رجعنا نفس أسامي البارامترز القديمة بتاعتك بالظبط عشان الماركت بليس يقراها وميجيبش إيرور
  final String categoryTitle;
  final String categoryKey;

  const CategoryProductsScreen({
    super.key, 
    required this.categoryTitle, 
    required this.categoryKey,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCartCount();
  }

  // تحديث عداد السلة اللي في الـ AppBar لايف من الفايربيس
  void _updateCartCount() {
    if (_uid == null) return;
    _db.child('users').child(_uid!).child('cart').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final cartData = event.snapshot.value as Map;
        if (mounted) {
          setState(() => _cartCount = cartData.length);
        }
      } else {
        if (mounted) setState(() => _cartCount = 0);
      }
    });
  }

  // دالة إضافة الوجبة للسلة في الفايربيس وتسميعها فوري
  Future<void> _addToCart(Map product) async {
    if (_uid == null) return;
    try {
      final cartRef = _db.child('users').child(_uid!).child('cart').push();
      await cartRef.set({
        'cartItemId': cartRef.key,
        'productId': product['productId'] ?? '',
        'name': product['name'] ?? '',
        'price': product['price'] ?? 0,
        'storeId': product['storeId'] ?? '',
        'storeName': product['storeName'] ?? 'مطعم معتمد',
        'quantity': 1,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة ${product['name']} إلى السلة 🛒'), 
            backgroundColor: const Color(0xFF00E5FF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عذراً، فشل إضافة المنتج'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0B121F);
    const Color fill = Color(0xFF1E203D);
    const Color accent = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, 
        elevation: 0, 
        foregroundColor: Colors.white,
        // بيعرض العنوان ديناميكي حسب الكاتجوري اللي العميل داس عليها (مطاعم، سوبرماركت...)
        title: Text(
          widget.categoryTitle, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          // 🛒 أيقونة السلة الحية بالعداد المظبوط فوق على اليمين
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: accent),
                onPressed: () {
                  // هنا نربط شاشة الكاشير أو السلة لما يجي دورها
                },
              ),
              if (_cartCount > 0)
                Positioned(
                  top: 6, 
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_cartCount', 
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), 
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder(
        // بنقرأ لايف من القسم العام الموحد باستخدام الـ categoryKey القديم بتاعك (زي: restaurants)
        stream: _db.child('products').child(widget.categoryKey).onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accent));
          }
          if (!snap.hasData || snap.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                'لا توجد وجبات متاحة في هذا القسم حالياً', 
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final productsList = (snap.data!.snapshot.value as Map).entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productsList.length,
            itemBuilder: (context, i) {
              final prod = productsList[i].value as Map;
              return Container(
                margin: const EdgeInsets.only(bottom: 14), 
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fill, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    // زرار الإضافة الذكي للسلة
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent, 
                        foregroundColor: bg, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: () => _addToCart(prod),
                      child: const Text('إضافة +', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const Spacer(),
                    // بيانات الوجبة والمطعم
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          prod['name'] ?? '', 
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prod['storeName'] ?? 'مطعم معتمد', 
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${prod['price']} EGP', 
                          style: const TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // أيقونة الوجبة الثابتة بلون الأكسنت المباشر زيرو إيرورز
                    Container(
                      width: 50, 
                      height: 50,
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.fastfood, color: accent, size: 24),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}