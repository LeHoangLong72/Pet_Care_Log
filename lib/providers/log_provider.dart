import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/daily_log_model.dart';
import '../models/medical_model.dart';
import '../services/notification_service.dart';

class LogProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<DailyLogModel> _allLogs = [];
  List<MedicalModel> _allMedicals = [];
  
  StreamSubscription? _logSub;
  StreamSubscription? _medicalSub;

  void updateUserId(String? userId) {
    _logSub?.cancel();
    _medicalSub?.cancel();
    
    if (userId == null) {
      _allLogs = [];
      _allMedicals = [];
      notifyListeners();
      return;
    }

    _logSub = _db.collection('logs')
        .where('ownerId', isEqualTo: userId)
        .snapshots().listen((snapshot) {
      _allLogs = snapshot.docs
          .map((doc) => DailyLogModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });

    _medicalSub = _db.collection('medicals')
        .where('ownerId', isEqualTo: userId)
        .snapshots().listen((snapshot) {
      _allMedicals = snapshot.docs
          .map((doc) => MedicalModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  // --- PHẦN NHẬT KÝ HÀNG NGÀY (DAILY LOG) ---

  List<DailyLogModel> getLogsForPet(String petId) {
    return _allLogs.where((log) => log.petId == petId).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<void> addLog(DailyLogModel log) async {
    await _db.collection('logs').doc(log.id).set(log.toMap());
  }

  Future<void> deleteLog(String logId) async {
    await _db.collection('logs').doc(logId).delete();
  }

  // --- PHẦN Y TẾ (MEDICAL) ---

  List<MedicalModel> getMedicalsForPet(String petId) {
    return _allMedicals.where((m) => m.petId == petId).toList()
      ..sort((a, b) => b.dateAdministered.compareTo(a.dateAdministered));
  }

  Future<void> addMedical(MedicalModel medical) async {
    await _db.collection('medicals').doc(medical.id).set(medical.toMap());
    
    // ĐỂ TEST: Thông báo sẽ hiện sau 5 giây kể từ khi bấm Lưu
    final testDate = DateTime.now().add(const Duration(seconds: 5));

    await NotificationService().scheduleNotification(
      id: medical.id.hashCode,
      title: 'Nhắc nhở chăm sóc thú cưng 🐾',
      body: 'Đã đến lịch ${medical.type == 'Vaccine' ? 'tiêm phòng' : 'tẩy giun'} cho bé rồi!',
      scheduledDate: testDate,
    );
  }

  Future<void> updateMedicalStatus(MedicalModel medical) async {
    await _db.collection('medicals').doc(medical.id).update({
      'isCompleted': medical.isCompleted,
    });
    
    // Nếu đã hoàn thành thì hủy thông báo nhắc nhở
    if (medical.isCompleted) {
      await NotificationService().cancelNotification(medical.id.hashCode);
    }
  }

  Future<void> deleteMedical(String medicalId) async {
    await _db.collection('medicals').doc(medicalId).delete();
    await NotificationService().cancelNotification(medicalId.hashCode);
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _medicalSub?.cancel();
    super.dispose();
  }
}
