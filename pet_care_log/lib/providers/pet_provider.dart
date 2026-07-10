import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import "../models/pet_model.dart";

class PetProvider extends ChangeNotifier {
  final Box<PetModel> _petBox = Hive.box<PetModel>('pets_box');

  // Lấy toàn bộ danh sách thú cưng từ Hive
  List<PetModel> get pets => _petBox.values.toList();

  // Thêm thú cưng mới
  Future<void> addPet(PetModel newPet) async {
    await _petBox.put(newPet.id, newPet);
    notifyListeners(); // Thông báo cho UI cập nhật giao diện
  }

  // Xóa thú cưng
  Future<void> deletePet(String id) async {
    await _petBox.delete(id);
    notifyListeners();
  }

  // Cập nhật thông tin cân nặng hoặc thông tin khác
  Future<void> updatePet(PetModel updatedPet) async {
    await updatedPet.save(); // Khả năng tự lưu rất tiện lợi của HiveObject
    notifyListeners();
  }
}