import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/daily_log_model.dart';
import '../models/medical_model.dart';

class LogProvider extends ChangeNotifier {
  final Box<DailyLogModel> _logBox = Hive.box<DailyLogModel>('logs_box');
  final Box<MedicalModel> _medicalBox = Hive.box<MedicalModel>('medicals_box');

  // --- PHẦN NHẬT KÝ HÀNG NGÀY (DAILY LOG) ---

  // Lấy nhật ký của một thú cưng cụ thể, sắp xếp theo thời gian mới nhất lên đầu
  List<DailyLogModel> getLogsForPet(String petId) {
    return _logBox.values
        .where((log) => log.petId == petId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Thêm nhật ký mới
  Future<void> addLog(DailyLogModel log) async {
    await _logBox.put(log.id, log);
    notifyListeners();
  }

  // Xóa nhật ký
  Future<void> deleteLog(String logId) async {
    await _logBox.delete(logId);
    notifyListeners();
  }

  // --- PHẦN Y TẾ (MEDICAL) ---

  // Lấy danh sách tiêm phòng/tẩy giun của một thú cưng
  List<MedicalModel> getMedicalsForPet(String petId) {
    return _medicalBox.values
        .where((m) => m.petId == petId)
        .toList()
      ..sort((a, b) => b.dateAdministered.compareTo(a.dateAdministered));
  }

  // Thêm bản ghi y tế
  Future<void> addMedical(MedicalModel medical) async {
    await _medicalBox.put(medical.id, medical);
    notifyListeners();
  }

  // Cập nhật trạng thái đã hoàn thành (Ví dụ: đã tiêm xong)
  Future<void> updateMedicalStatus(MedicalModel medical) async {
    await medical.save();
    notifyListeners();
  }
}
