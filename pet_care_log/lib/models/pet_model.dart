import 'package:hive/hive.dart';

part 'pet_model.g.dart'; // File này sẽ tự sinh ra sau khi chạy lệnh build_runner

@HiveType(typeId:0)
class PetModel extends HiveObject{
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime birthDate;

  @HiveField(3)
  String breed;

  @HiveField(4)
  double weight;

  @HiveField(5)
  String? imagePath;

  PetModel({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.breed,
    required this.weight,
    this.imagePath,
  });
}