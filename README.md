# PetCareLog 🐾 - Nhật Ký Chăm Sóc Thú Cưng

**PetCareLog** là một ứng dụng di động được xây dựng bằng Flutter, giúp người nuôi thú cưng dễ dàng theo dõi sức khỏe, lịch trình ăn uống và các mốc y tế quan trọng. Ứng dụng hoạt động **Offline 100%**, đảm bảo dữ liệu cá nhân được lưu trữ an toàn trên thiết bị của bạn.

## 🚀 Tính Năng Chính

### 1. Quản lý Hồ sơ Thú cưng
* Tạo hồ sơ riêng cho nhiều thú cưng (Chó, Mèo, v.v.).
* Lưu trữ thông tin: Tên, Giống, Cân nặng, Ngày sinh và Ảnh đại diện.

### 2. Nhật ký Hoạt động (Timeline)
* Ghi chép các hoạt động hàng ngày theo dạng dòng thời gian trực quan.
* Phân loại hoạt động: **Ăn uống**, **Vệ sinh**, và **Triệu chứng lạ**.
* Dễ dàng theo dõi lịch sử sinh hoạt để sớm phát hiện các dấu hiệu bất thường về sức khỏe.

### 3. Sổ Y tế & Nhắc lịch Thông minh
* Lưu trữ lịch sử **Tiêm phòng (Vaccine)** và **Tẩy giun (Deworming)**.
* Tự động tính toán ngày hẹn kế tiếp dựa trên loại dịch vụ.
* **Hệ thống cảnh báo:** Hiển thị thông báo "Sắp đến hạn" hoặc "Quá hạn" ngay tại màn hình chính khi ngày hẹn y tế gần kề.

## 🛠 Công Nghệ Sử Dụng

*   **Framework:** Flutter (Material 3)
*   **Database:** [Hive](https://pub.dev/packages/hive) (Cơ sở dữ liệu NoSQL tốc độ cao, lưu trữ local).
*   **State Management:** [Provider](https://pub.dev/packages/provider) (Quản lý trạng thái ứng dụng đơn giản và hiệu quả).
*   **Local Images:** Sử dụng `image_picker` để chọn ảnh từ thư viện thiết bị.
*   **Utilities:** `intl` (Định dạng ngày tháng), `uuid` (Tạo định danh duy nhất).

## 📂 Cấu Trúc Thư Mục

```text
lib/
├── models/         # Định nghĩa cấu trúc dữ liệu (Pet, DailyLog, Medical)
├── providers/      # Quản lý logic nghiệp vụ và tương tác Database
├── views/          # Giao diện người dùng (Home, Profile, Timeline)
└── main.dart       # Điểm khởi chạy & Cấu hình dịch vụ
```

## 📸 Ảnh Chụp Màn Hình

*(Bạn có thể thêm hình ảnh thực tế của ứng dụng tại đây)*

## 🛠 Cài Đặt

1.  **Clone dự án:**
    ```bash
    git clone https://github.com/your-username/pet_care_log.git
    ```
2.  **Cài đặt dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Chạy build_runner (để tạo Hive Adapters):**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Chạy ứng dụng:**
    ```bash
    flutter run
    ```

---
Dự án được phát triển với mục tiêu học tập và hỗ trợ cộng đồng yêu thú cưng. 🐾
