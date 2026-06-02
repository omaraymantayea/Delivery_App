import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 🔥 استخدام الباكيج المستقرة عندك تماماً

class DriverGpsTrackingTab extends StatefulWidget {
  const DriverGpsTrackingTab({super.key});
  @override
  State<DriverGpsTrackingTab> createState() => _DriverGpsTrackingTabState();
}

class _DriverGpsTrackingTabState extends State<DriverGpsTrackingTab> {
  double _latitude = 30.0444;
  double _longitude = 31.2357;
  bool _isLoading = true;
  GoogleMapController? _mapController; // كونتولر جوجل مابس
  final String? _driverId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  void _initTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    
    if (mounted) {
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _isLoading = false;
      });
    }

    // التتبع اللحظي للكابتن
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        // تحريك الكاميرا بسلاسة في جوجل مابس
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
      _uploadLoc(position.latitude, position.longitude);
    });
  }

  void _uploadLoc(double lat, double lng) async {
    if (_driverId == null) return;
    try {
      await FirebaseFirestore.instance.collection('active_drivers').doc(_driverId).set({
        'driverId': _driverId,
        'latitude': lat,
        'longitude': lng,
        'lastUpdate': FieldValue.serverTimestamp(),
        'isOnline': true,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("❌ Firebase Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)))
        : Stack(
            children: [
              // 🌍 خريطة جوجل الرسمية والمستقرة في فلاتر بدون باكيج latlong2 خارجي
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(_latitude, _longitude),
                  zoom: 16.0,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true, // يظهر نقطة اللوكيشن الزرقاء الرسمية لجوجل
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                // وضع ماركر على مكان الكابتن الحالي
                markers: {
                  Marker(
                    markerId: const MarkerId('driver_loc'),
                    position: LatLng(_latitude, _longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange), // ماركر برتقالي متناسق مع الدارك ثيم
                  ),
                },
              ),
              
              // 📑 اللوحة العصرية الشفافة فوق الخريطة
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14162E).withValues(alpha: 0.9), 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.2)), 
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.gps_fixed_rounded, color: Color(0xFFFFB300), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'نظام التتبع والخرائط نشط ويرسل اللوكيشن لايف',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}