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
      return e.message;
    } on TimeoutException {
      debugPrint("Auth: Lỗi quá thời gian (Timeout). Có thể do reCAPTCHA bị chặn.");
      return "Kết nối quá lâu. Vui lòng kiểm tra internet hoặc thử lại.";
    } catch (e) {
      debugPrint("Auth: Lỗi lạ: $e");
      return e.toString();
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
      return e.message;
    } on TimeoutException {
      debugPrint("Auth: Lỗi quá thời gian (Timeout).");
      return "Kết nối quá lâu. Vui lòng thử lại.";
    } catch (e) {
      debugPrint("Auth: Lỗi lạ: $e");
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
