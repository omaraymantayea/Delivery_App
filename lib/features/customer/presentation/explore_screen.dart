import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:delivery_app/core/routes/app_routes.dart';

import 'widgets/marketplace_categories.dart';
import 'profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _currentIndex = 0;

  // شاشات التنقل تحت - شيلنا الـ const النهائي منها ومن عناصرها
  late final List<Widget> _screens = [
    ExploreBodyWidgets(),
    const Center(
      child: Text(
        'Tracking & Maps Screen',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // تعريف الألوان كمتغيرات عادية جوه الـ build عشان نخلص من قفلة الـ const
    final bg = const Color(0xFF1E203D);
    final accent = const Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: bg,
              elevation: 0,
              title: const Text(
                'Explore / استكشف',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_rounded,
                      color: accent, size: 26),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.checkout);
                  },
                ),
                const SizedBox(width: 12),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: bg,
        selectedItemColor: accent,
        unselectedItemColor: Colors.white38,
        currentIndex: _currentIndex,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ExploreBodyWidgets extends StatelessWidget {
  const ExploreBodyWidgets({super.key});

  // تحديد اللون هنا كـ final عادي مش const عشان ينهي الإيرور تماماً
  final Color accentColor = const Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference storesRef =
        FirebaseDatabase.instance.ref().child('stores');

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.explore);
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14162E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: accentColor.withOpacity(0.3), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: accentColor, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Restaurants, groceries, pharmacies...',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const MarketplaceCategories(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Featured Stores / المطاعم والمتاجر',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: storesRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return _buildMockStoresList(context, accentColor);
                }

                try {
                  final Map<dynamic, dynamic> storesMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final List<dynamic> storeList = storesMap.values.toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: storeList.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final store = storeList[index] as Map<dynamic, dynamic>;
                      return _buildStoreCard(
                        context: context,
                        name: store['storeName'] ?? 'Unnamed Store',
                        type: store['storeType'] ?? 'General',
                        address: store['address'] ?? 'No address',
                        accent: accentColor,
                      );
                    },
                  );
                } catch (e) {
                  return _buildMockStoresList(context, accentColor);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMockStoresList(BuildContext context, Color accent) {
    final List<Map<String, String>> mockStores = [
      {
        'name': 'La Piazza',
        'type': 'Pizza & Pasta',
        'address': '90th Street, Fifth Settlement'
      },
      {
        'name': 'McDonalds',
        'type': 'Fast Food',
        'address': 'Cairo International University'
      },
      {
        'name': 'El Ezaby Pharmacy',
        'type': 'Pharmacy',
        'address': 'Delivery 24/7'
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockStores.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final store = mockStores[index];
        return _buildStoreCard(
          context: context,
          name: store['name']!,
          type: store['type']!,
          address: store['address']!,
          accent: accent,
        );
      },
    );
  }

  Widget _buildStoreCard({
    required BuildContext context,
    required String name,
    required String type,
    required String address,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.partnerRegistration);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF14162E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.restaurant_rounded, color: accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(type,
                        style: TextStyle(
                            color: accent.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
