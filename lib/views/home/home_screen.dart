import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/log_provider.dart';
import '../../models/pet_model.dart';
import '../profile/profile_screen.dart';
import '../timeline/timeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final petList = petProvider.pets;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PetCareLog 🐾',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: petList.isEmpty
          ? const Center(
              child: Text(
                'Chưa có thú cưng nào.\nHãy bấm nút (+) để thêm mới!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: petList.length,
              itemBuilder: (context, index) {
                final pet = petList[index];
                return _buildPetCard(context, pet, petProvider);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetModel pet, PetProvider provider) {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final medicals = logProvider.getMedicalsForPet(pet.id);
    
    bool hasReminder = false;
    String reminderText = "";
    
    final now = DateTime.now();
    for (var m in medicals) {
      final difference = m.nextDueDate.difference(now).inDays;
      if (difference >= 0 && difference <= 7) {
        hasReminder = true;
        reminderText = "Sắp đến hạn ${m.type == 'Vaccine' ? 'tiêm phòng' : 'tẩy giun'} ($difference ngày)";
        break;
      } else if (difference < 0 && !m.isCompleted) {
         hasReminder = true;
         reminderText = "Quá hạn ${m.type == 'Vaccine' ? 'tiêm phòng' : 'tẩy giun'}!";
         break;
      }
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: pet.imagePath != null && pet.imagePath!.isNotEmpty && File(pet.imagePath!).existsSync()
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: FileImage(File(pet.imagePath!)),
                  )
                : const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.tealAccent,
                    child: Icon(Icons.pets, color: Colors.teal, size: 30),
                  ),
            title: Text(
              pet.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giống: ${pet.breed} • ${pet.weight} kg',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.history, size: 14, color: Colors.teal[300]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          logProvider.getLogsForPet(pet.id).isNotEmpty
                              ? 'Cuối: ${logProvider.getLogsForPet(pet.id).first.title}'
                              : 'Chưa có hoạt động',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.teal),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(pet: pet),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _showDeleteDialog(context, pet, provider);
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimelineScreen(petId: pet.id),
                ),
              );
            },
          ),
          if (hasReminder)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notification_important, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    reminderText,
                    style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PetModel pet, PetProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa hồ sơ?'),
          content: Text('Bạn có chắc chắn muốn xóa hồ sơ của bé ${pet.name} không? Dữ liệu không thể khôi phục.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                provider.deletePet(pet.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa hồ sơ của ${pet.name}')),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
