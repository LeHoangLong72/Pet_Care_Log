import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String?> signUp(String email, String password) async {
    try {
      debugPrint("Auth: Đang bắt đầu đăng ký cho $email...");
      await _auth.createUserWithEmailAndPassword(email: email, password: password).timeout(const Duration(seconds: 15));
      debugPrint("Auth: Đăng ký thành công!");
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Auth: Lỗi Firebase (${e.code}): ${e.message}");
      return _translateError(e.code);
    } on TimeoutException {
      debugPrint("Auth: Lỗi quá thời gian (Timeout). Có thể do reCAPTCHA bị chặn.");
      return "Kết nối quá lâu. Vui lòng kiểm tra internet hoặc thử lại.";
    } catch (e) {
      debugPrint("Auth: Lỗi lạ: $e");
      return "Đã có lỗi xảy ra. Vui lòng thử lại.";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      debugPrint("Auth: Đang bắt đầu đăng nhập cho $email...");
      await _auth.signInWithEmailAndPassword(email: email, password: password).timeout(const Duration(seconds: 15));
      debugPrint("Auth: Đăng nhập thành công!");
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Auth: Lỗi Firebase (${e.code}): ${e.message}");
      return _translateError(e.code);
    } on TimeoutException {
      debugPrint("Auth: Lỗi quá thời gian (Timeout).");
      return "Kết nối quá lâu. Vui lòng thử lại.";
    } catch (e) {
      debugPrint("Auth: Lỗi lạ: $e");
      return "Đã có lỗi xảy ra. Vui lòng thử lại.";
    }
  }

  String _translateError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Tài khoản hoặc mật khẩu không chính xác.';
      case 'wrong-password':
        return 'Tài khoản hoặc mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký bởi một tài khoản khác.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt.';
      case 'invalid-credential':
        return 'Tài khoản hoặc mật khẩu không chính xác.';
      case 'too-many-requests':
        return 'Yêu cầu quá thường xuyên. Vui lòng thử lại sau vài phút.';
      case 'channel-error':
        return 'Vui lòng nhập đầy đủ thông tin.';
      default:
        return 'Đã có lỗi xảy ra. Vui lòng thử lại ($code).';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
