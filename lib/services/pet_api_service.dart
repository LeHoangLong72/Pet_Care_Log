import 'dart:convert';
import 'package:http/http.dart' as http;

class PetApiService {
  // Sử dụng Cat Facts API công khai (REST API)
  static const String _baseUrl = 'https://catfact.ninja/fact';

  Future<String> getRandomPetFact() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['fact'] ?? 'Không tìm thấy thông tin bổ ích nào.';
      } else {
        throw Exception('Lỗi khi tải dữ liệu từ API');
      }
    } catch (e) {
      return 'Không thể kết nối tới máy chủ API để lấy thông tin thú cưng.';
    }
  }
}
