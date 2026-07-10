import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/log_provider.dart';
import '../../models/pet_model.dart';
import '../../models/daily_log_model.dart';
import '../profile/profile_screen.dart';

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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // Hiển thị ảnh đại diện (Nếu có path thì lấy từ máy, không thì hiện icon mặc định)
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
            // Hiển thị hộp thoại xác nhận xóa
            _showDeleteDialog(context, pet, provider);
          },
        ),
        onTap: () async {
          // Lấy LogProvider mà không cần lắng nghe sự thay đổi UI ở đây (listen: false)
          final logProvider = Provider.of<LogProvider>(context, listen: false);

          // 1. Thêm một nhật ký giả lập để test
          final testLog = DailyLogModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            petId: pet.id,
            dateTime: DateTime.now(),
            logType: 'Food',
            title: 'Test: Bé đã ăn hạt',
            note: 'Ăn lúc ${DateTime.now().hour}:${DateTime.now().minute}',
          );

          await logProvider.addLog(testLog);

          // 2. Lấy danh sách nhật ký của riêng bé này ra Console để kiểm tra
          final petLogs = logProvider.getLogsForPet(pet.id);
          print("--- NHẬT KÝ CỦA BÉ ${pet.name.toUpperCase()} ---");
          print("Tổng số bản ghi: ${petLogs.length}");
          for (var log in petLogs) {
            print(">> [${log.dateTime}] ${log.title} - ${log.note}");
          }

          // 3. Thông báo cho người dùng
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm 1 nhật ký cho ${pet.name}. Kiểm tra Console!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
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