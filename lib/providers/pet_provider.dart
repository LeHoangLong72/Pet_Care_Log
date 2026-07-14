import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "../models/pet_model.dart";

class PetProvider extends ChangeNotifier {
  final CollectionReference _petCollection =
      FirebaseFirestore.instance.collection('pets');

  List<PetModel> _pets = [];
  List<PetModel> get pets => _pets;
  StreamSubscription? _subscription;

  // Cập nhật việc lắng nghe theo userId
  void updateUserId(String? userId) {
    _subscription?.cancel();
    if (userId == null) {
      _pets = [];
      notifyListeners();
      return;
    }

    _subscription = _petCollection
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _pets = snapshot.docs
          .map((doc) =>
              PetModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addPet(PetModel newPet) async {
    await _petCollection.doc(newPet.id).set(newPet.toMap());
  }

  Future<void> deletePet(String id) async {
    await _petCollection.doc(id).delete();
  }

  Future<void> updatePet(PetModel updatedPet) async {
    await _petCollection.doc(updatedPet.id).update(updatedPet.toMap());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
