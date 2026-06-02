import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db =
      FirebaseDatabase.instance; // الاعتماد على الـ Realtime

  // 1. تسجيل الدخول بالإيميل والباسورد
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'حدث خطأ أثناء تسجيل الدخول');
    }
  }

  // 2. إنشاء حساب جديد بالإيميل وتحديد الرتبة (customer / driver / admin / store_admin)
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // حفظ البيانات في مسار users داخل الـ Realtime Database
        await _db.ref().child('users').child(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'role': role,
          'createdAt': ServerValue.timestamp, // البديل الذكي لـ serverTimestamp
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'حدث خطأ أثناء إنشاء الحساب');
    }
  }

  // 3. تسجيل الدخول بجوجل مع الحفظ في الـ Realtime Database
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // الفحص في الـ Realtime Database هل المستخدم موجود مسبقاً؟
        final userSnapshot = await _db
            .ref()
            .child('users')
            .child(userCredential.user!.uid)
            .get();

        if (!userSnapshot.exists) {
          await _db.ref().child('users').child(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'name': userCredential.user!.displayName ?? 'مستخدم جوجل',
            'email': userCredential.user!.email ?? '',
            'role': 'customer', // الافتراضي عميل
            'createdAt': ServerValue.timestamp,
          });
        }
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'حدث خطأ أثناء التسجيل بجوجل');
    }
  }

  // 4. تسجيل الخروج
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
