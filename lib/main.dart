import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_care_log/models/daily_log_model.dart';
import 'package:pet_care_log/models/medical_model.dart';
import 'package:pet_care_log/models/pet_model.dart';
import 'package:pet_care_log/providers/pet_provider.dart';
import 'package:pet_care_log/providers/log_provider.dart';
import 'package:pet_care_log/views/home/home_screen.dart';
import 'package:provider/provider.dart';


void main() async{
  // Đảm bảo các dịch vụ native của Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive
  await Hive.initFlutter();

  // Đăng ký các Adapter để Hive đọc được dữ liệu Custom Object
  Hive.registerAdapter(PetModelAdapter());
  Hive.registerAdapter(DailyLogModelAdapter());
  Hive.registerAdapter(MedicalModelAdapter());

  // Mở sẵn các Box dữ liệu (Tương tự như mở các bảng trong SQL)
  await Hive.openBox<PetModel>('pets_box');
  await Hive.openBox<DailyLogModel>('logs_box');
  await Hive.openBox<MedicalModel>('medicals_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // Khởi tạo các Provider quản lý State tại đây
          ChangeNotifierProvider(create: (_) => PetProvider()),
          ChangeNotifierProvider(create: (_) => LogProvider()),
        ],
      child: MaterialApp(
        title: 'PetCareLog',
        theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
        home:  const HomeScreen(),
      ),
    );
  }
}


