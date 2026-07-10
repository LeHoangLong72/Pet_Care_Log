import 'package:hive/hive.dart';

part 'daily_log_model.g.dart';

@HiveType(typeId: 1)
class DailyLogModel extends HiveObject{
@HiveType(typeId: 3)
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String petId; // Khóa ngoại liên kết với PetModel

  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  final String logType; // 'Food', 'Waste', hoặc 'Symptom' để đơn giản hóa Enum

  @HiveField(4)
  String title; // V dụ: "Ăn hạt Royal Canin", "Đi bậy ngoài thảm"

  @HiveField(5)
  String note; // Chi tiết: "Ăn hết 50g", "Phân hơi lỏng"

  DailyLogModel({
    required this.id,
    required this.petId,
    required this.dateTime,
    required this.logType,
    required this.title,
    required this.note
  });
}