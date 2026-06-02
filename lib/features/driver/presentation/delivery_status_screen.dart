import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryStatusScreen extends StatefulWidget {
  const DeliveryStatusScreen({super.key});

  @override
  State<DeliveryStatusScreen> createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  GoogleMapController? _mapCtrl;

  // إحداثيات افتراضية بتبدأ منها الخريطة لحد ما الجي بي اس يلقط لايف
  static const LatLng _center = LatLng(30.0444, 31.2357); 

  @override
  Widget build(BuildContext context) {
    const Color bg = Color(0xFF1E203D);
    const Color surface = Color(0xFF14162E);
    const Color accent = Color(0xFF00E5FF);

    if (_uid == null) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(child: Text('يرجى تسجيل الدخول أولاً', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, centerTitle: true,
        title: const Text('Live Tracking / تتبع الطلب لايف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: StreamBuilder(
        // 🛰️ بنقرأ لايف من فرع التتبع الخاص بطلب هذا العميل الحالي
        stream: _db.child('users').child(_uid!).child('current_order_tracking').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accent));
          }

          Set<Marker> markers = {};
          String status = "جاري تأكيد الطلب...";
          String driverName = "جاري تخصيص سائق...";

          // لو التاجر أو الدليفري رفعوا بيانات التحرك لايف للعميل
          if (snap.hasData && snap.data!.snapshot.value != null) {
            final trackingData = snap.data!.snapshot.value as Map;
            final double lat = trackingData['latitude'] ?? 30.0444;
            final double lng = trackingData['longitude'] ?? 31.2357;
            status = trackingData['status'] ?? 'في الطريق إليك';
            driverName = trackingData['driverName'] ?? 'كابتن التوصيل';

            // تحريك الكاميرا تلقائياً مع حركة السائق
            _mapCtrl?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));

            // إضافة ماركر السائق على الخريطة بلون الأكسنت المميز
            markers.add(
              Marker(
                markerId: const MarkerId('driver_position'),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(title: driverName, snippet: status),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
              ),
            );
          }

          return Stack(
            children: [
              // 1. الخريطة الأساسية
              GoogleMap(
                initialCameraPosition: const CameraPosition(target: _center, zoom: 14),
                markers: markers,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) => _mapCtrl = controller,
              ),

              // 2. كارت حالة الطلب الشفاف اللي فوق الخريطة (شغل شركات فخم)
              Positioned(
                bottom: 20, left: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(status, style: const TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const Text('حالة الطلب الحالية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      Row(
                        children: [
                          CircleAvatar(backgroundColor: bg, child: const Icon(Icons.directions_bike, color: accent)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driverName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const Text('يندفع بأقصى سرعة لتوصيل طعامك حاراً ⚡', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}