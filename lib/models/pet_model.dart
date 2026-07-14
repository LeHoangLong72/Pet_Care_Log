import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String ownerId; // Thêm ID người chủ
  String name;
  DateTime birthDate;
  String breed;
  double weight;
  String? imagePath;

  PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.birthDate,
    required this.breed,
    required this.weight,
    this.imagePath,
  });

  factory PetModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PetModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      breed: map['breed'] ?? '',
      weight: (map['weight'] as num).toDouble(),
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'breed': breed,
      'weight': weight,
      'imagePath': imagePath,
    };
  }
}
