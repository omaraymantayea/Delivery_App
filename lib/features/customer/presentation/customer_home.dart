import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _isLoading = true; // عشان نعمل تأثير التحميل الذكي اللي في الصورة

  // لستة المتاجر التجريبية اللي هتنزل تحت الكاتجوري وتوقف اللودر
  final List<Map<String, String>> _mockStores = [
    {
      'name': 'مطعم البرنس',
      'category': 'مأكولات شرقية',
      'rating': '⭐ 4.9',
      'deliveryTime': '25-35 دقيقة',
      'image': '🍔'
    },
    {
      'name': 'بيتزا كينج',
      'category': 'بيتزا ومعجنات',
      'rating': '⭐ 4.7',
      'deliveryTime': '20-30 دقيقة',
      'image': '🍕'
    },
    {
      'name': 'صيدلية العزبي',
      'category': 'أدوية ومستحضرات',
      'rating': '⭐ 5.0',
      'deliveryTime': '15-20 دقيقة',
      'image': '💊'
    },
  ];

  @override
  void initState() {
    super.initState();
    // بنحاكي إن الأبلكيشن بيحمل الداتا من السيرفر لمدة ثانية ونص وبعدين يقفل اللودر
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBg = Color(0xFF131928); // نفس الدرجة الفخمة اللي في صورتك
    const accentColor = Color(0xFF00bcd4); // الأزرق السماوي للأيقونات

    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1️⃣ بار البحث (زي اللي في الصورة بالظبط)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2434),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: accentColor),
                    hintText: 'Restaurants, groceries, pharmacies...',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 2️⃣ صف الكاتجوري الذكي (مربوط بصفحات مخصصة عند الضغط)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryItem(context, 'مطاعم', Icons.restaurant, accentColor, 'restaurants'),
                  _buildCategoryItem(context, 'سوبرماركت', Icons.shopping_basket, accentColor, 'groceries'),
                  _buildCategoryItem(context, 'صيدلية', Icons.local_pharmacy, accentColor, 'pharmacies'),
                  _buildCategoryItem(context, 'هدايا', Icons.card_giftcard, accentColor, 'gifts'),
                ],
              ),
              const SizedBox(height: 35),

              // 3️⃣ عنوان القسم الرئيسي
              const Text(
                'Featured Stores / المطاعم والمتاجر',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 4️⃣ مكان الدايرة اللي بتلف (اللودر اللي في صورتك)
              _isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: CircularProgressIndicator(color: accentColor),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mockStores.length,
                      itemBuilder: (context, index) {
                        final store = _mockStores[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2434),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: primaryBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: Text(store['image']!, style: const TextStyle(fontSize: 30))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(store['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(store['category']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(store['rating']!, style: const TextStyle(color: Colors.amber, fontSize: 12)),
                                        const SizedBox(width: 12),
                                        Icon(Icons.access_time, color: accentColor, size: 12),
                                        const SizedBox(width: 4),
                                        Text(store['deliveryTime']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت بناء زرار الكاتجوري مع تفعيل فتح صفحة مخصصة له
  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, Color accentColor, String categoryKey) {
    return GestureDetector(
      onTap: () {
        // لما يدوس على الكاتجوري بيفتح صفحة الفلترة المخصصة له
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryDetailsScreen(categoryTitle: title, categoryKey: categoryKey)),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1C2434),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 📂 الشاشة الداخلية اللي بتفتح لكل كاتجوري (CategoryDetailsScreen)
// -----------------------------------------------------------------
class CategoryDetailsScreen extends StatelessWidget {
  final String categoryTitle;
  final String categoryKey;

  const CategoryDetailsScreen({super.key, required this.categoryTitle, required this.categoryKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131928),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2434),
        title: Text(categoryTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, size: 80, color: const Color(0xFF00bcd4).withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'جميع متاجر قسم: $categoryTitle',
              style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم سحب المنيو الخاص بهذا القسم لايف من الفايربيز',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}