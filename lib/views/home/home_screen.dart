import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/log_provider.dart';
import '../../models/pet_model.dart';
import '../../services/pet_api_service.dart';
import '../profile/profile_screen.dart';
import '../timeline/timeline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _petFact = "Đang tải kiến thức thú cưng...";
  final PetApiService _apiService = PetApiService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadFact();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFact() async {
    final fact = await _apiService.getRandomPetFact();
    if (mounted) {
      setState(() {
        _petFact = fact;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final filteredPets = petProvider.pets.where((pet) {
      return pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             pet.breed.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền sáng nhẹ để nổi bật Search Bar
      appBar: AppBar(
        title: const Text(
          'PetCareLog 🐾',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF00695C)),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM THEO MẪU CỦA BẠN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Bo tròn tuyệt đối
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thú cưng...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none, // Loại bỏ viền mặc định
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // 2. Ô KIẾN THỨC (REST API)
          _buildFactCard(),
          
          // 3. DANH SÁCH THÚ CƯNG
          Expanded(
            child: petProvider.pets.isEmpty
                ? _buildEmptyState()
                : filteredPets.isEmpty
                    ? _buildNoResultsState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPets.length,
                        itemBuilder: (context, index) => _buildPetCard(context, filteredPets[index], petProvider),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm thú cưng'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFactCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              const Text("Bạn có biết?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              const Spacer(),
              GestureDetector(
                onTap: _loadFact,
                child: const Icon(Icons.refresh, size: 18, color: Colors.teal),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_petFact, style: const TextStyle(fontSize: 13, color: Colors.black87, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetModel pet, PetProvider provider) {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Hero(
          tag: 'pet-${pet.id}',
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: pet.imagePath != null && File(pet.imagePath!).existsSync()
                  ? DecorationImage(image: FileImage(File(pet.imagePath!)), fit: BoxFit.cover)
                  : null,
              color: Colors.teal.shade50,
            ),
            child: pet.imagePath == null || !File(pet.imagePath!).existsSync()
                ? const Icon(Icons.pets, color: Colors.teal) : null,
          ),
        ),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Text('${pet.breed} • ${pet.weight}kg', style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TimelineScreen(petId: pet.id))),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("Chưa có thú cưng nào 🐾"));
  Widget _buildNoResultsState() => const Center(child: Text("Không tìm thấy kết quả nào 🔍"));
}
