import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/daily_log_model.dart';
import '../../models/medical_model.dart';
import '../../models/pet_model.dart';
import '../../providers/log_provider.dart';
import '../../providers/pet_provider.dart';

class TimelineScreen extends StatelessWidget {
  final String petId;

  const TimelineScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin Pet để có ownerId
    final pet = Provider.of<PetProvider>(context).pets.firstWhere((p) => p.id == petId);
    final logProvider = Provider.of<LogProvider>(context, listen: false);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(pet.breed, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
            ],
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
                onPressed: () {
                  final index = DefaultTabController.of(context).index;
                  if (index == 0) {
                    _DailyLogTab.showAddLog(context, pet, logProvider);
                  } else {
                    _MedicalTab.showAddMedical(context, pet, logProvider);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Nhật ký'),
              Tab(text: 'Y tế'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DailyLogTab(pet: pet),
            _MedicalTab(pet: pet),
          ],
        ),
      ),
    );
  }
}

// --- TAB NHẬT KÝ HÀNG NGÀY ---
class _DailyLogTab extends StatelessWidget {
  final PetModel pet;
  const _DailyLogTab({required this.pet});

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);
    final logs = logProvider.getLogsForPet(pet.id);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded, size: 48, color: colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  Text('Chưa có nhật ký', style: TextStyle(color: colorScheme.outline)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) => _buildTimelineItem(context, logs[index]),
            ),
    );
  }

  static void showAddLog(BuildContext context, PetModel pet, LogProvider provider) {
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
                      petId: pet.id,
                      ownerId: pet.ownerId,
                      dateTime: DateTime.now(),
                      logType: selectedType,
                      title: titleController.text,
                      note: noteController.text,
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C), minimumSize: const Size(double.infinity, 45)),
                child: const Text('LƯU NHẬT KÝ', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, DailyLogModel log) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData icon;
    Color color;

    switch (log.logType) {
      case 'Food':
        icon = Icons.restaurant_rounded;
        color = Colors.orange;
        break;
      case 'Waste':
        icon = Icons.cleaning_services_rounded;
        color = Colors.brown;
        break;
      case 'Symptom':
        icon = Icons.warning_amber_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.info_outline_rounded;
        color = colorScheme.primary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Container(
              width: 2,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      DateFormat('HH:mm - dd/MM').format(log.dateTime),
                      style: TextStyle(fontSize: 11, color: colorScheme.outline),
                    ),
                  ],
                ),
                if (log.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.note,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: colorScheme.error),
                    onPressed: () => _showDeleteLogConfirm(context, log),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteLogConfirm(BuildContext context, DailyLogModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhật ký?'),
        content: const Text('Bạn có chắc muốn xóa dòng nhật ký này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Provider.of<LogProvider>(context, listen: false).deleteLog(log.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
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
                      petId: pet.id,
                      ownerId: pet.ownerId, // Thêm ownerId từ PetModel
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
  final PetModel pet;
  const _MedicalTab({required this.pet});

  @override
  Widget build(BuildContext context) {
    final logProvider = Provider.of<LogProvider>(context);
    final medicals = logProvider.getMedicalsForPet(pet.id);

    return Scaffold(
      body: medicals.isEmpty
          ? const Center(child: Text('Chưa có lịch sử y tế.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicals.length,
              itemBuilder: (context, index) {
                final m = medicals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            m.type == 'Vaccine' ? Icons.vaccines : Icons.bug_report,
                            color: m.isCompleted ? Colors.green : Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.type == 'Vaccine' ? 'Tiêm phòng' : 'Tẩy giun',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ngày: ${DateFormat('dd/MM/yyyy').format(m.dateAdministered)}\nHẹn: ${DateFormat('dd/MM/yyyy').format(m.nextDueDate)}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            if (!m.isCompleted)
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.only(bottom: 8),
                                icon: const Icon(Icons.check_circle_outline, color: Colors.orange),
                                onPressed: () {
                                  m.isCompleted = true;
                                  logProvider.updateMedicalStatus(m);
                                },
                              ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                              onPressed: () => _showDeleteMedicalConfirm(context, m),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  static void showAddMedical(BuildContext context, PetModel pet, LogProvider provider) {
    String selectedType = 'Vaccine';
    DateTime adminDate = DateTime.now();
    DateTime nextDate = DateTime.now().add(const Duration(days: 365));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Thêm bản ghi y tế', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    if (selectedType == 'Vaccine') {
                      nextDate = adminDate.add(const Duration(days: 365));
                    } else {
                      nextDate = adminDate.add(const Duration(days: 90));
                    }
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Loại dịch vụ'),
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
                    petId: pet.id,
                    ownerId: pet.ownerId,
                    type: selectedType,
                    dateAdministered: adminDate,
                    nextDueDate: nextDate,
                    isCompleted: adminDate.day == DateTime.now().day && 
                               adminDate.month == DateTime.now().month &&
                               adminDate.year == DateTime.now().year,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C), minimumSize: const Size(double.infinity, 45)),
                child: const Text('LƯU THÔNG TIN', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteMedicalConfirm(BuildContext context, MedicalModel medical) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bản ghi y tế?'),
        content: const Text('Dữ liệu tiêm phòng này sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Provider.of<LogProvider>(context, listen: false).deleteMedical(medical.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddMedicalDialog(BuildContext context, LogProvider provider) {
    String selectedType = 'Vaccine';
    DateTime adminDate = DateTime.now();
    DateTime nextDate = DateTime.now().add(const Duration(days: 365));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Thêm bản ghi y tế', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    if (selectedType == 'Vaccine') {
                      nextDate = adminDate.add(const Duration(days: 365));
                    } else {
                      nextDate = adminDate.add(const Duration(days: 90));
                    }
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Loại dịch vụ'),
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
                    petId: pet.id,
                    ownerId: pet.ownerId, // Thêm ownerId từ PetModel
                    type: selectedType,
                    dateAdministered: adminDate,
                    nextDueDate: nextDate,
                    isCompleted: adminDate.day == DateTime.now().day && 
                               adminDate.month == DateTime.now().month &&
                               adminDate.year == DateTime.now().year,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 45)),
                child: const Text('LƯU THÔNG TIN', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
