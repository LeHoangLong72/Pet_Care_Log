import 'package:hive/hive.dart';

part 'medical_model.g.dart'; // Sẽ tự sinh sau khi chạy build_runner

@HiveType(typeId: 2)
class MedicalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String petId; // Khóa ngoại liên kết với PetModel

  @HiveField(2)
  final String type; // 'Vaccine' hoặc 'Deworming'

  @HiveField(3)
  DateTime dateAdministered; // Ngày thực hiện tiêm/tẩy giun

  @HiveField(4)
  DateTime nextDueDate; // Ngày hẹn kế tiếp để app tính toán cảnh báo

  @HiveField(5)
  bool isCompleted; // Trạng thái đã hoàn thành hay chưa

  MedicalModel({
    required this.id,
    required this.petId,
    required this.type,
    required this.dateAdministered,
    required this.nextDueDate,
    this.isCompleted = false, // Mặc định khi tạo lịch nhắc là chưa hoàn thành
  });
}