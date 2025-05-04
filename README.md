<<<<<<< HEAD
# ThucTap
=======
# Nghiên cứu lập trình di động trên nền tảng Android để xây dựng ứng dụng tìm kiếm việc làm công nghệ thông tin bằng framework Flutter và ngôn ngữ lập trình Dart

##  Giới thiệu

Đây là đề tài nghiên cứu và phát triển một ứng dụng di động đa nền tảng (sử dụng Flutter) nhằm kết nối người tìm việc và nhà tuyển dụng trong lĩnh vực Công nghệ Thông tin. Ứng dụng hỗ trợ tìm kiếm việc làm, quản lý hồ sơ cá nhân, đăng tuyển, và theo dõi công việc một cách thuận tiện.

---

## Mục tiêu

- Nghiên cứu khả năng lập trình di động đa nền tảng với Flutter.
- Xây dựng ứng dụng tìm kiếm việc làm tập trung vào lĩnh vực CNTT.
- Hỗ trợ người tìm việc tiếp cận nhanh chóng với các cơ hội việc làm.
- Giúp nhà tuyển dụng dễ dàng quản lý và đăng tin tuyển dụng.

---

## ⚙️ Công nghệ sử dụng

- **Flutter & Dart**: Sử dụng để xây dựng ứng dụng di động đa nền tảng (Android và iOS) với giao diện người dùng linh hoạt và hiệu suất cao.
- **Supabase**: Là một nền tảng backend mã nguồn mở dùng để lưu trữ cơ sở dữ liệu, xác thực người dùng, và xử lý các truy vấn thời gian thực.
- **SharedPreferences**: Dùng để lưu trữ dữ liệu cục bộ như danh sách công việc yêu thích hoặc trạng thái đăng nhập.
- **Git**: Sử dụng để quản lý mã nguồn, theo dõi thay đổi và làm việc nhóm hiệu quả.

---

## Tính năng chính

### Người tìm việc (Job Seeker)
- Đăng ký/đăng nhập
- Cập nhật hồ sơ cá nhân, avatar
- Tìm kiếm và lọc công việc theo từ khóa
- Lưu công việc yêu thích
- Xem danh sách việc làm phổ biến và gần đây

### Nhà tuyển dụng (Recruiter)
- Đăng ký tài khoản và chờ Admin duyệt
- Đăng tin tuyển dụng
- Quản lý danh sách việc làm đã đăng
- Xem danh sách ứng viên ứng tuyển

### Quản trị viên (Admin)
- Duyệt tài khoản nhà tuyển dụng
- Quản lý, ẩn/hiện, xoá bài đăng tuyển dụng
- Quản lý công ty và ứng viên

---

## Cấu trúc thư mục
lib/
├── models/ # Định nghĩa mô hình dữ liệu
├── services/ # Dịch vụ tương tác Supabase
├── pages/ # Các màn hình UI (HomePage, AdminPage, ...)
├── components/ # Các widget tái sử dụng
├── main.dart # Điểm khởi chạy ứng dụng
 
---
##  Cài đặt và chạy ứng dụng

### Bước 1: Cài đặt Flutter SDK

Nếu bạn chưa cài đặt Flutter:

1. Truy cập trang chính thức: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. Tải về Flutter SDK và giải nén.
3. Thêm đường dẫn `flutter/bin` vào biến môi trường (`Path`) trên máy tính.
4. Kiểm tra cài đặt thành công bằng lệnh:

   ```bash
   flutter --version
   ```

---

### Bước 2: Cài đặt IDE (Android Studio hoặc VS Code)

- **Android Studio** (khuyên dùng):
  - Cài đặt Flutter Plugin và Dart Plugin trong phần Plugin.
  - Bật Android Emulator để kiểm tra ứng dụng trên máy ảo.

- **VS Code**:
  - Cài đặt extensions: `Flutter` và `Dart`.

---

### Bước 3: Clone và chạy ứng dụng

```bash
# 1. Clone dự án từ GitHub
git clone https://github.com/Trang25112003/ThucTap
cd ThucTapThucTap

# 2. Cài đặt các gói phụ thuộc
flutter pub get

# 3. Kiểm tra thiết bị đang kết nối
flutter devices

# 4. Chạy ứng dụng trên thiết bị/emulator
flutter run
```

---

### Bước 4: Cấu hình Supabase

1. Tạo tài khoản tại: [https://supabase.com](https://supabase.com)
2. Tạo một project mới.
3. Tạo các bảng: `accounts`, `users`, `jobs`, `business`, v.v.
4. Lấy **Supabase URL** và **anon/public API key** trong phần `Project Settings`.
5. Thêm thông tin vào file cấu hình trong Flutter, ví dụ `lib/constants.dart`:

```dart
const String supabaseUrl = 'https://your-project.supabase.co';
const String supabaseKey = 'your-public-anon-key';
```

6. Khởi tạo client Supabase ở `main.dart` hoặc file khởi tạo:

```dart
final supabase = SupabaseClient(supabaseUrl, supabaseKey);
```

---

### Bước 5: Build hoặc xuất bản ứng dụng

- Chạy ứng dụng:
  ```bash
  flutter run
  ```

- Build file `.apk` để cài đặt trên thiết bị Android:
  ```bash
  flutter build apk
  ```

- Sau khi build thành công, file APK sẽ nằm trong thư mục `build/app/outputs/flutter-apk/app-release.apk`.

---

## Liên hệ

-  Email: lttrang25@gmail.com
-  Sinh viên: Lê Thị Trang - Đại học Sư phạm, Đại học Đà Nẵng
-  Đề tài nghiên cứu: Nghiên cứu lập trình di động trên nền tảng Android để xây dựng ứng dụng tìm kiếm việc làm công nghệ thông tin bằng framework Flutter và ngôn ngữ lập trình Dart


>>>>>>> 41e589d (initial comit)
