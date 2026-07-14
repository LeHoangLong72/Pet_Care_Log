import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLogModel {
  final String id;
  final String petId;
  final String ownerId; // Thêm ownerId
  final DateTime dateTime;
  final String logType;
  String title;
  String note;

  DailyLogModel({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.dateTime,
    required this.logType,
    required this.title,
    required this.note,
  });

  factory DailyLogModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DailyLogModel(
      id: documentId,
      petId: map['petId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      logType: map['logType'] ?? 'Food',
      title: map['title'] ?? '',
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'dateTime': Timestamp.fromDate(dateTime),
      'logType': logType,
      'title': title,
      'note': note,
    };
  }
}
