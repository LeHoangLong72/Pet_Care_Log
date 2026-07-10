import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _selectedDate;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null){
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Hàm chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate){
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Hàm lưu dữ liệu
  void _savePet(){
    if (_formKey.currentState!.validate() && _selectedDate != null){
      final petProvider = Provider.of<PetProvider>(context, listen: false);

      final newPet = PetModel(
        id: const Uuid().v4(), // Tạo ID duy nhất
        name: _nameController.text,
        breed: _breedController.text,
        birthDate: _selectedDate!,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        imagePath: _imageFile?.path,
      );

      petProvider.addPet(newPet);
      Navigator.pop(context); // Quay lại màn hình chính
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày sinh')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Thú Cưng'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Khu vực chọn ảnh đại diện
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal[50],
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.teal)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên thú cưng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Giống loài',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập giống' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Cân nặng (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập cân nặng' : null,
              ),
              const SizedBox(height: 15),
              // Chọn ngày sinh
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                title: Text(_selectedDate == null
                    ? 'Chọn ngày sinh'
                    : 'Ngày sinh: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today, color: Colors.teal),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('LƯU HỒ SƠ', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}