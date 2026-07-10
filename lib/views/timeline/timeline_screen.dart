import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/daily_log_model.dart';
import '../../models/medical_model.dart';
import '../../providers/log_provider.dart';
import '../../providers/pet_provider.dart';

class TimelineScreen extends StatelessWidget {
  final String petId;

  const TimelineScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    final pet = Provider.of<PetProvider>(context).pets.firstWhere((p) => p.id == petId);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hồ sơ bé ${pet.name}'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.history), text: 'Nhật ký'),
              Tab(icon: Icon(Icons.medical_services), text: 'Y tế'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DailyLogTab(petId: petId),
            _MedicalTab(petId: petId),
          ],
        ),
      ),
    );
  }
}

// --- TAB NHẬT KÝ HÀNG NGÀY ---
class _DailyLogTab extends StatelessWidget {
  final String petId;
  const _DailyLogTab({required this.petId});

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);
    final logs = logProvider.getLogsForPet(petId);

    return Scaffold(
      body: logs.isEmpty
          ? const Center(child: Text('Chưa có hoạt động nào.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) => _buildTimelineItem(logs[index]),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_log',
        onPressed: () => _showAddLogBottomSheet(context, logProvider),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildTimelineItem(DailyLogModel log) {
    IconData icon;
    Color color;

    switch (log.logType) {
      case 'Food':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'Waste':
        icon = Icons.cleaning_services;
        color = Colors.brown;
        break;
      case 'Symptom':
        icon = Icons.warning_amber_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.blue;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(width: 2, height: 15, color: Colors.grey[300]),
              Icon(icon, color: color, size: 24),
              Expanded(child: Container(width: 2, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(log.note),
                trailing: Text(DateFormat('HH:mm\ndd/MM').format(log.dateTime),
                    textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLogBottomSheet(BuildContext context, LogProvider provider) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    String selectedType = 'Food';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ghi chép hoạt động', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'Food', child: Text('Ăn uống')),
                  DropdownMenuItem(value: 'Waste', child: Text('Vệ sinh')),
                  DropdownMenuItem(value: 'Symptom', child: Text('Triệu chứng lạ')),
                ],
                onChanged: (val) => setModalState(() => selectedType = val!),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Loại hoạt động'),
              ),
              const SizedBox(height: 10),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề (VD: Ăn hạt)')),
              TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Ghi chú')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    provider.addLog(DailyLogModel(
                      id: const Uuid().v4(),
                      petId: petId,
                      dateTime: DateTime.now(),
                      logType: selectedType,
                      title: titleController.text,
                      note: noteController.text,
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 45)),
                child: const Text('LƯU NHẬT KÝ', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TAB Y TẾ (VACCINE & TẨY GIUN) ---
class _MedicalTab extends StatelessWidget {
  final String petId;
  const _MedicalTab({required this.petId});

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);
    final medicals = logProvider.getMedicalsForPet(petId);

    return Scaffold(
      body: medicals.isEmpty
          ? const Center(child: Text('Chưa có lịch sử y tế.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicals.length,
              itemBuilder: (context, index) {
                final m = medicals[index];
                return Card(
                  child: ListTile(
                    leading: Icon(m.type == 'Vaccine' ? Icons.vaccines : Icons.bug_report,
                        color: m.isCompleted ? Colors.green : Colors.orange),
                    title: Text('${m.type == 'Vaccine' ? 'Tiêm phòng' : 'Tẩy giun'}'),
                    subtitle: Text('Ngày thực hiện: ${DateFormat('dd/MM/yyyy').format(m.dateAdministered)}\nHẹn tiếp theo: ${DateFormat('dd/MM/yyyy').format(m.nextDueDate)}'),
                    trailing: m.isCompleted ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pending, color: Colors.orange),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_medical',
        onPressed: () => _showAddMedicalDialog(context, logProvider),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_moderator, color: Colors.white),
      ),
    );
  }

  void _showAddMedicalDialog(BuildContext context, LogProvider provider) {
    String selectedType = 'Vaccine';
    DateTime adminDate = DateTime.now();
    DateTime nextDate = DateTime.now().add(const Duration(days: 365)); // Mặc định 1 năm

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Thêm bản ghi y tế',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'Vaccine', child: Text('Tiêm phòng')),
                  DropdownMenuItem(value: 'Deworming', child: Text('Tẩy giun')),
                ],
                onChanged: (val) {
                  setModalState(() {
                    selectedType = val!;
                    // Tự động gợi ý ngày tiếp theo: Vaccine +1 năm, Tẩy giun +3 tháng
                    if (selectedType == 'Vaccine') {
                      nextDate = adminDate.add(const Duration(days: 365));
                    } else {
                      nextDate = adminDate.add(const Duration(days: 90));
                    }
                  });
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Loại dịch vụ'),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Ngày thực hiện'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(adminDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: adminDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModalState(() => adminDate = picked);
                  }
                },
              ),
              ListTile(
                title: const Text('Ngày hẹn tiếp theo'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(nextDate)),
                trailing: const Icon(Icons.calendar_today, color: Colors.orange),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: nextDate,
                    firstDate: adminDate,
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setModalState(() => nextDate = picked);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  provider.addMedical(MedicalModel(
                    id: const Uuid().v4(),
                    petId: petId,
                    type: selectedType,
                    dateAdministered: adminDate,
                    nextDueDate: nextDate,
                    isCompleted: true,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 45)),
                child: const Text('LƯU THÔNG TIN',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
