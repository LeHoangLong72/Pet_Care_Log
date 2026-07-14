import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalModel {
  final String id;
  final String petId;
  final String ownerId; // Thêm ownerId
  final String type;
  DateTime dateAdministered;
  DateTime nextDueDate;
  bool isCompleted;

  MedicalModel({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.type,
    required this.dateAdministered,
    required this.nextDueDate,
    this.isCompleted = false,
  });

  factory MedicalModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MedicalModel(
      id: documentId,
      petId: map['petId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      type: map['type'] ?? 'Vaccine',
      dateAdministered: (map['dateAdministered'] as Timestamp).toDate(),
      nextDueDate: (map['nextDueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'type': type,
      'dateAdministered': Timestamp.fromDate(dateAdministered),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'isCompleted': isCompleted,
    };
  }
}
