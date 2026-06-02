import 'package:flutter/material.dart';
import '../category_products_screen.dart';

class MarketplaceCategories extends StatelessWidget {
  const MarketplaceCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Restaurants / مطاعم',
        'tooltip': 'مطاعم',
        'icon': Icons.restaurant,
        'id': 'restaurants'
      },
      {
        'name': 'Groceries / سوبرماركت',
        'tooltip': 'سوبرماركت',
        'icon': Icons.shopping_basket,
        'id': 'groceries'
      },
      {
        'name': 'Pharmacy / صيدلية',
        'tooltip': 'صيدلية',
        'icon': Icons.local_pharmacy,
        'id': 'pharmacies'
      },
      {
        'name': 'Gifts / هدايا',
        'tooltip': 'هدايا',
        'icon': Icons.card_giftcard,
        'id': 'gifts'
      },
    ];

    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Tooltip(
              message: cat['name'] as String,
              textStyle: const TextStyle(
                  color: Color(0xFF1E203D), fontWeight: FontWeight.bold),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryProductsScreen(
                        categoryTitle: cat['tooltip'] as String,
                        categoryKey: cat['id'] as String,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E203D),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.05),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: const Color(0xFF00E5FF),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
