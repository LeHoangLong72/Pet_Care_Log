import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/log_provider.dart';
import '../../models/pet_model.dart';
import '../../models/daily_log_model.dart';
import '../profile/profile_screen.dart';
import '../timeline/timeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi dữ liệu từ PetProvider
    final petProvider = Provider.of<PetProvider>(context);
    final petList = petProvider.pets; // Lấy danh sách thú cưng từ Hive

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PetCareLog 🐾',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
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
          // Thay thế nội dung bên trong onPressed bằng lệnh chuyển trang dưới đây:
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

  // Widget Widget tạo Card cho từng thú cưng
  Widget _buildPetCard(BuildContext context, PetModel pet, PetProvider provider) {
    // Lấy LogProvider để kiểm tra nhắc lịch
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    final medicals = logProvider.getMedicalsForPet(pet.id);
    
    // Tìm xem có lịch nhắc nào sắp đến (trong 7 ngày tới) hoặc đã quá hạn không
    bool hasReminder = false;
    String reminderText = "";
    
    final now = DateTime.now();
    for (var m in medicals) {
      final difference = m.nextDueDate.difference(now).inDays;
      if (difference >= 0 && difference <= 7) {
        hasReminder = true;
        reminderText = "Sắp đến hạn ${m.type == 'Vaccine' ? 'tiêm phòng' : 'tẩy giun'} (${difference} ngày)";
        break;
      } else if (difference < 0 && !m.isCompleted) {
         // Nếu quá hạn mà chưa đánh dấu hoàn thành (tính năng mở rộng sau này)
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
            leading: pet.imagePath != null && pet.imagePath!.isNotEmpty
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
              child: Text(
                'Giống: ${pet.breed} • Cân nặng: ${pet.weight} kg',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                _showDeleteDialog(context, pet, provider);
              },
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

  // Hộp thoại xác nhận xóa thú cưng khỏi Hive
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
                provider.deletePet(pet.id); // Gọi hàm xóa từ Provider
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