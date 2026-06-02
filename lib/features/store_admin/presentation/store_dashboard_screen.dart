import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 🗺️ مكتبة الجي بي اس والخرائط
import 'add_product_screen.dart'; 

class StoreDashboardScreen extends StatefulWidget {
  const StoreDashboardScreen({super.key});

  @override
  State<StoreDashboardScreen> createState() => _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> {
  int _idx = 1; // الافتراضي يفتح على قائمة الطعام
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _db = FirebaseDatabase.instance.ref();
  String _storeName = "جاري التحميل...";
  
  GoogleMapController? _mapCtrl;
  // إحداثيات افتراضية (مثلاً القاهرة) لحد ما الـ GPS يلقط لايف
  static const LatLng _initialPosition = LatLng(30.0444, 31.2357); 

  @override
  void initState() {
    super.initState();
    _loadStoreName();
  }

  void _loadStoreName() async {
    if (_uid == null) return;
    final snap = await _db.child('stores').child(_uid!).child('businessName').get();
    if (snap.exists && mounted) {
      setState(() => _storeName = snap.value.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF0B121F);
    const Color accent = Color(0xFF00E5FF);
    
    // 🎯 الأربع شاشات كاملين بالترتيب الحقيقي بتاعهم
    final tabs = [
      _ordersView(), 
      _menuView(),
      const Center(child: Text('الأداء والأرباح 📈', style: TextStyle(color: Colors.white70, fontSize: 16))),
      _trackView(), // 🗺️ شاشة التتبع لايف بالـ GPS
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF1E203D), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 4),
                  Text('طبيعي', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_storeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text('ID: ${_uid ?? "N/A"}', style: const TextStyle(color: accent, fontSize: 9, fontFamily: 'monospace')),
              ],
            ),
          ],
        ),
      ),
      body: tabs[_idx],
      // 🎯 رجعنا الـ 4 عناصر كاملين في الـ BottomNavigationBar عشان تفتح الصفحة الرابعة براحتك
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx, backgroundColor: const Color(0xFF1E203D),
        selectedItemColor: accent, unselectedItemColor: Colors.white54, type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.soup_kitchen), label: 'المطبخ والطلبات'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'قائمة الطعام'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'الأداء والأرباح'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'تتبع السائقين'), // الصفحة الرابعة الحية
        ],
      ),
    );
  }

  Widget _menuView() {
    if (_uid == null) return const Center(child: Text('خطأ في تحديد هوية المتجر', style: TextStyle(color: Colors.white)));
    return Stack(
      children: [
        StreamBuilder(
          stream: _db.child('stores').child(_uid!).child('menu').onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
            }
            if (!snap.hasData || snap.data!.snapshot.value == null) {
              return const Center(child: Text('قائمة الطعام فارغة حالياً.\nأضف وجبتك الأولى! 👇', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)));
            }
            final menu = (snap.data!.snapshot.value as Map).entries.toList();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), 
              itemCount: menu.length,
              itemBuilder: (context, i) {
                final item = menu[i].value as Map;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E203D), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note, color: Colors.white54), 
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(item['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('${item['price']} EGP', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 45, height: 45, 
                        decoration: BoxDecoration(color: const Color(0xFF0B121F), borderRadius: BorderRadius.circular(10)), 
                        child: const Icon(Icons.fastfood, color: Color(0xFF00E5FF)),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16, left: 16, right: 16,
          child: SizedBox(
            height: 52,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF00E5FF), foregroundColor: const Color(0xFF0B121F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
              label: const Text('إضافة وجبة للمنيو +', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        )
      ],
    );
  }

  Widget _ordersView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _orderCard('#ORD-9542', 'بيج ماك كومبو + بطاطس حجم عائلي x2', 'جاري التحضير', true),
        _orderCard('#ORD-9543', 'بيتزا رانش حجم كبير + لتر كولا x1', 'الأكل جاهز', false),
      ],
    );
  }

  Widget _orderCard(String id, String content, String status, bool prep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E203D), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: prep ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: prep ? Colors.orangeAccent : Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Spacer(), 
              Text(id, style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          Text(content, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: IconButton(icon: const Icon(Icons.flash_on, color: Colors.amber), onPressed: () {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: const Color(0xFF0B121F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () {}, 
                    child: const Text('تحديث الحالة', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 🎯 شاشة التتبع الرابعة الحقيقية الشغالة بالـ GPS لايف
  Widget _trackView() {
    return StreamBuilder(
      // بنقرأ لايف من فرع طلبات المتجر الحالي لمعرفة اللوكيشن بتاع الدليفري
      stream: _db.child('stores').child(_uid ?? 'unknown').child('active_deliveries').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)));
        }

        // لو مفيش أوردر طالع حالياً، بنعرض الخريطة ثابتة مع رسالة توضيحية لشغل الشركات الاحترافي
        Set<Marker> markers = {};
        if (snap.hasData && snap.data!.snapshot.value != null) {
          final deliveryData = snap.data!.snapshot.value as Map;
          final double lat = deliveryData['latitude'] ?? 30.0444;
          final double lng = deliveryData['longitude'] ?? 31.2357;
          
          markers.add(
            Marker(
              markerId: const MarkerId('driver_loc'),
              position: LatLng(lat, lng),
              infoWindow: const InfoWindow(title: 'موقع السائق الحالي 🚴'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            ),
          );
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(target: _initialPosition, zoom: 12),
              markers: markers,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) => _mapCtrl = controller,
            ),
            Positioned(
              top: 16, left: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1E203D).withOpacity(0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      markers.isEmpty ? 'لا توجد طلبات قيد التوصيل حالياً' : 'يتم الآن تتبع السائق لايف عبر الـ GPS 🛰️',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Icon(markers.isEmpty ? Icons.info_outline : Icons.g_mobiledata, color: const Color(0xFF00E5FF)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}