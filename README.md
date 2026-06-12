#  Nexus Talent — Student Job Finder App

[![Flutter Version](https://img.shields.io/badge/Flutter-%3E%3D_3.4.0-blue.svg?logo=flutter)](https://flutter.dev)
[![Firebase Cloud Services](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-orange.svg?logo=firebase)](https://firebase.google.com)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20Clean-emerald.svg)](https://flutter.dev)
[![State Management](https://img.shields.io/badge/State--Management-Riverpod-violet.svg)](https://riverpod.dev)

**Nexus Talent** (Student Job App) là một ứng dụng tìm kiếm việc làm chuyên biệt dành cho sinh viên, được phát triển trên nền tảng **Flutter** với hiệu năng vượt trội và giao diện hiện đại. Ứng dụng tích hợp sâu với **Firebase** (Authentication, Cloud Firestore, Cloud Storage, Cloud Functions) cung cấp đầy đủ chức năng cho cả hai đối tượng: **Sinh viên** tìm việc và **Nhà tuyển dụng** đăng tin & quản lý hồ sơ ứng viên.

Ứng dụng hỗ trợ cơ chế chạy offline hoặc chạy bằng dữ liệu mock linh hoạt qua tệp cấu hình trung tâm, dễ dàng chuyển đổi sang hệ thống production trong vài giây.

---

##  Giao diện & Trải nghiệm Người dùng
- **Thiết kế Hiện đại (Premium UI):** Sử dụng phông chữ cao cấp (Google Fonts Outfit/Inter), bảng màu gradient hiện đại, hỗ trợ hiệu ứng kính mờ (**Glassmorphism**) trên AppBar tăng tính thẩm mỹ.
- **Tab Navigation linh hoạt:** Hệ thống tab bền bỉ sử dụng `StatefulShellRoute` của GoRouter giúp chuyển đổi mượt mà giữa các tab chính mà không bị mất vị trí cuộn trang.
- **Nhãn trạng thái trực quan:** Mọi thông tin trạng thái ứng tuyển được ánh xạ màu sắc và icon nhất quán giúp người dùng nắm bắt thông tin tức thì.

---

##  Tính năng Nổi bật

### 1. Phân hệ dành cho Sinh viên
* **Xác thực & Bảo mật:** Đăng ký và đăng nhập tài khoản nhanh chóng, hỗ trợ ghi nhớ phiên đăng nhập.
* **Tìm kiếm & Lọc thông minh:** Tìm kiếm công việc thời gian thực theo từ khóa, lọc theo danh mục ngành nghề (Category), địa điểm, loại hình công việc (Full-time, Part-time, Remote, Internship) và nguồn tin tuyển dụng.
* **Chi tiết công việc chuyên sâu:** Hiển thị rõ ràng mô tả công việc, yêu cầu ứng viên, quyền lợi được hưởng.
* **Yêu thích & Lưu tin tuyển dụng:** Lưu lại các tin tuyển dụng quan tâm vào danh sách yêu thích, hỗ trợ lưu trữ cục bộ offline bằng SharedPreferences.
* **Nộp hồ sơ trực tuyến:** Cho phép tải lên CV dạng PDF hoặc Word lên **Firebase Storage**, tự động liên kết CV vào hồ sơ cá nhân và gửi đơn ứng tuyển trực tiếp đến nhà tuyển dụng.
* **Theo dõi trạng thái thời gian thực:** Xem lịch sử các công việc đã nộp cùng trạng thái phản hồi chi tiết của nhà tuyển dụng (*Đang chờ duyệt / Đang xem xét / Phỏng vấn / Đã duyệt nhận / Đã từ chối*).

### 2. Phân hệ dành cho Nhà tuyển dụng (Recruiter)
* **Đăng tin tuyển dụng (CRUD):** Giao diện biểu mẫu trực quan hỗ trợ đăng tin tuyển dụng mới, chỉnh sửa thông tin tin tuyển dụng hiện có, hoặc xóa tin đã đăng.
* **Đóng/Mở tin tuyển dụng:** Thay đổi nhanh trạng thái tin tuyển dụng để ẩn hoặc hiển thị tin với các ứng viên sinh viên.
* **Quản lý danh sách ứng viên:** Xem chi tiết các hồ sơ sinh viên đã ứng tuyển vào từng bài viết tuyển dụng.
* **Duyệt hồ sơ & Phản hồi:** Mở trực tiếp CV của ứng viên, cập nhật trạng thái hồ sơ ứng tuyển và viết phản hồi (Feedback) gửi lại trực tiếp cho sinh viên.

---

##  Công nghệ & Thư viện sử dụng (Tech Stack)

| Thư viện / Công nghệ | Vai trò trong dự án |
| -------------------- | ------------------- |
| **Flutter SDK** | Bộ công cụ phát triển ứng dụng đa nền tảng từ mã nguồn duy nhất. |
| **Flutter Riverpod** | Quản lý trạng thái ứng dụng (State Management) độc lập giao diện và logic. |
| **GoRouter** | Định tuyến (Routing) điều hướng trang, xử lý phân quyền và liên kết sâu. |
| **Firebase Auth** | Xác thực người dùng, bảo mật đăng nhập/đăng ký tài khoản. |
| **Cloud Firestore** | Cơ sở dữ liệu NoSQL lưu trữ thông tin người dùng, công việc, và đơn ứng tuyển. |
| **Firebase Storage** | Lưu trữ tệp tin đám mây, sử dụng để tải lên và lưu trữ các tệp CV của sinh viên. |
| **Dio** | Thư viện HTTP Client gọi API ngoài lấy dữ liệu tin tuyển dụng bổ sung. |
| **Shared Preferences**| Lưu trữ dữ liệu cấu hình cục bộ, tin yêu thích và lịch sử ứng tuyển khi chạy Mock/Offline. |
| **Google Fonts** | Nhúng font Outfit & Inter tăng tính thẩm mỹ cao cấp cho giao diện. |

---

##  Cấu trúc Dự án (Folder Structure)

Mã nguồn được tổ chức theo kiến trúc **Feature-First Clean Architecture** để dễ dàng bảo trì và mở rộng khi dự án phát triển lớn:

```text
lib/
├── firebase_options.dart         # Cấu hình tự động kết nối dự án Firebase của từng nền tảng
├── main.dart                     # Entry point khởi tạo Widget binding, Firebase và khởi chạy app
│
├── app/                          # Định tuyến và luồng điều hướng toàn hệ thống
│   ├── app.dart                  # Thiết lập MaterialApp.router và ThemeData toàn cục
│   ├── app_routes.dart           # Khai báo tập trung danh sách các Route Paths và điều kiện phân quyền
│   └── router.dart               # Cấu hình GoRouter, StatefulShellRoute và phân quyền người dùng (Guards)
│
├── core/                         # Các thành phần dùng chung (Shared Modules)
│   ├── config/                   # Cấu hình hệ thống, nhãn trạng thái và cấu hình vai trò
│   │   ├── app_config.dart       # Cấu hình Bật/Tắt Firebase, API, hay thiết lập URL API
│   │   ├── app_strings.dart      # Quản lý chuỗi văn bản giao diện tập trung
│   │   ├── application_status_ui.dart # Ánh xạ nhãn, màu sắc và icon cho trạng thái duyệt hồ sơ
│   │   ├── cv_utils.dart         # Tiện ích định dạng và validate tệp CV
│   │   ├── job_ui_labels.dart    # Định nghĩa nhãn ngành nghề và loại hình công việc
│   │   └── user_roles.dart       # Quản lý vai trò (student / recruiter)
│   ├── theme/                    # Cấu hình giao diện và bảng màu
│   │   ├── app_theme.dart        # Cấu hình ThemeData và text theme đồng bộ
│   │   └── stitch_colors.dart    # Định nghĩa mã màu Gradient độc quyền Stitch
│   └── widgets/                  # UI Components tái sử dụng
│       ├── app_empty_state.dart  # Màn hình trống (khi không tìm thấy kết quả hoặc danh sách rỗng)
│       ├── app_section_title.dart# Tiêu đề mục tiêu chuẩn hóa
│       ├── stitch_glass_app_bar.dart # Thanh AppBar hiệu ứng kính mờ (Glassmorphism)
│       └── stitch_main_shell.dart# Layout chứa thanh điều hướng Tab Bar dưới cùng
│
└── features/                     # Chia mã nguồn theo các tính năng nghiệp vụ độc lập
    ├── auth/                     # Tính năng Xác thực người dùng (Đăng nhập / Đăng ký)
    │   ├── data/auth_service.dart     # Xử lý tương tác Firebase Auth và lưu trữ role trên Firestore
    │   └── presentation/              # Trạng thái đăng nhập và màn hình đăng nhập/đăng ký tài khoản
    │
    ├── jobs/                     # Tính năng Tìm kiếm, lọc và xem chi tiết công việc
    │   ├── domain/job_model.dart      # Thực thể dữ liệu mô tả một công việc
    │   ├── data/                      # Đọc từ local JSON, API dịch vụ ngoài và Firestore nhà tuyển dụng
    │   └── presentation/              # Trạng thái danh sách, bộ lọc, trang chủ và chi tiết công việc
    │
    ├── applications/             # Tính năng Ứng tuyển công việc (Dành cho Sinh viên)
    │   ├── domain/applied_job_model.dart # Thực thể lưu thông tin lịch sử ứng tuyển
    │   └── presentation/              # Thực hiện nộp đơn (lưu Firestore / local) và xem lịch sử ứng tuyển
    │
    ├── favorites/                # Tính năng Lưu tin tuyển dụng yêu thích (Saved Bookmarks)
    │   └── presentation/              # Lưu/xóa tin yêu thích cục bộ qua SharedPreferences
    │
    ├── profile/                  # Tính năng Hồ sơ cá nhân của Sinh viên
    │   └── presentation/              # Quản lý thông tin cá nhân và tải lên CV (.pdf/.doc) lên Storage
    │
    └── recruiter/                # Tính năng dành riêng cho Nhà tuyển dụng
        ├── data/recruiter_jobs_repository.dart # Thao tác CRUD tin tuyển dụng trên Firestore
        └── presentation/              # Giao diện đăng tin, quản lý tin đã đăng và duyệt hồ sơ ứng viên
```

---

##  Hướng dẫn Cài đặt & Khởi chạy ứng dụng

### 1. Chuẩn bị môi trường
- Đã cài đặt **Flutter SDK** (Phiên bản `>= 3.4.0`).
- Đã cài đặt **Dart SDK**.
- Đã cấu hình và kết nối thiết bị ảo (Emulator) hoặc thiết bị thật kết nối qua cổng USB.

### 2. Cài đặt các thư viện phụ thuộc (Dependencies)
Tải và cập nhật toàn bộ thư viện khai báo trong `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Khởi chạy ứng dụng
Chạy ứng dụng trên thiết bị đã chọn:
```bash
flutter run
```

*Lưu ý:* Mặc định ứng dụng đã được cấu hình bật kết nối Firebase (`AppConfig.useFirebase = true`). Cấu hình dự án nằm trong tệp [firebase_options.dart](file:///d:/student_job_app_full_project/lib/firebase_options.dart).

---

##  Triển khai và Cấu hình Firebase (Firebase Deployment)

Dự án đã được liên kết sẵn với Project ID: `student-job-app-1d837` (Được lưu trong [.firebaserc](file:///d:/student_job_app_full_project/.firebaserc)).

### 1. Cài đặt dependencies backend (Firebase Functions)
Trước khi deploy Firebase Cloud Functions, hãy cài đặt các thư viện Node.js cần thiết trong thư mục functions:
- **Trên Windows PowerShell (5.x) hoặc cũ hơn (Chạy từng dòng một):**
  ```powershell
  cd functions
  npm install
  cd ..
  ```
- **Trên Bash hoặc PowerShell 7+ (Dùng lệnh &&):**
  ```bash
  cd functions && npm install && cd ..
  ```

### 2. Deploy Firestore Rules và Indexes lên Firebase
Cập nhật quy tắc bảo mật dữ liệu và tạo các chỉ mục hỗ trợ tìm kiếm/sắp xếp trên Firestore Database:
```bash
firebase deploy --only firestore:rules,firestore:indexes --project student-job-app-1d837
```

### 3. Cấu hình các dịch vụ bổ sung trên Firebase Console:
* **Firebase Storage:**
  Truy cập [Firebase Console → Storage](https://console.firebase.google.com/project/student-job-app-1d837/storage) để bật và khởi tạo bộ lưu trữ Cloud Storage. Sau đó, deploy quy tắc bảo mật của Storage lên hệ thống:
  ```bash
  firebase deploy --only storage:rules --project student-job-app-1d837
  ```
* **Cloud Functions:**
  Để sử dụng dịch vụ Cloud Functions (tính năng đăng tin, cập nhật trạng thái nâng cao), dự án Firebase của bạn cần được nâng cấp lên gói trả phí **Blaze (Pay-as-you-go)**. Khi đã nâng cấp, deploy functions bằng lệnh:
  ```bash
  firebase deploy --only functions --project student-job-app-1d837
  ```

---

## Quy tắc Bảo mật & Phân quyền (Security Rules)

### 1. Quy tắc Firestore (`firestore.rules`)
- **Bộ sưu tập `users`:** Chỉ người dùng đã đăng nhập mới có quyền đọc thông tin tài khoản người khác. Chỉ chính chủ sở hữu tài khoản mới có quyền ghi/chỉnh sửa thông tin tài khoản của mình.
- **Bộ sưu tập `jobs`:**
  - Mọi người (cả khách và sinh viên chưa đăng nhập) đều có quyền đọc tin tuyển dụng đang mở (`status == 'open'`).
  - Chỉ Nhà tuyển dụng tạo ra bài viết mới có quyền chỉnh sửa thông tin bài viết (`request.auth.uid == resource.data.createdBy`) hoặc xóa bài viết.
- **Bộ sưu tập `applications`:**
  - Chỉ sinh viên nộp hồ sơ mới có quyền tạo đơn ứng tuyển của mình.
  - Chỉ sinh viên đó hoặc nhà tuyển dụng của tin tuyển dụng tương ứng mới có quyền đọc hồ sơ ứng tuyển đó.
  - Chỉ nhà tuyển dụng của công việc đó mới có quyền cập nhật trạng thái đơn duyệt hồ sơ ứng tuyển.

### 2. Quy tắc Storage (`storage.rules`)
- Cho phép sinh viên đăng nhập thực hiện tải lên/chỉnh sửa tệp CV trong thư mục cá nhân `cvs/{userId}/{fileName}`.
- Cho phép nhà tuyển dụng đọc/tải tệp CV của ứng viên nộp cho tin tuyển dụng của họ.

---

## 👥 Tài khoản Thử nghiệm (Demo Accounts)

Khi ứng dụng chạy trong chế độ kết nối Firebase, bạn có thể tạo tài khoản trực tiếp trên giao diện ứng dụng:

| Vai trò người dùng | Cách tạo tài khoản | Khả năng trên hệ thống |
| ------------------ | ------------------ | ---------------------- |
| **Sinh viên** | Đăng ký tài khoản mới → Chọn vai trò **Sinh viên** | Tìm việc, lưu tin yêu thích, tải lên CV cá nhân, ứng tuyển công việc, theo dõi phản hồi từ nhà tuyển dụng. |
| **Nhà tuyển dụng** | Đăng ký tài khoản mới → Chọn vai trò **Nhà tuyển dụng** | Đăng bài tuyển dụng, cập nhật/xóa bài đăng, đóng/mở tin tuyển dụng, xem danh sách ứng tuyển, duyệt và gửi phản hồi cho sinh viên. |

### Kịch bản Demo nhanh:
1. **Kiểm thử Sinh viên:** Đăng nhập tài khoản Sinh viên -> Tìm kiếm công việc -> Tải lên CV tại tab Cá nhân -> Bấm nút Ứng tuyển ở một tin tuyển dụng -> Theo dõi tại tab "Hoạt động đã nộp" của tôi.
2. **Kiểm thử Nhà tuyển dụng:** Đăng nhập tài khoản Nhà tuyển dụng -> Vào phần Quản lý đăng tin -> Bấm Đăng tin tuyển dụng mới -> Quay lại trang ứng viên của bài tuyển dụng đó để xem hồ sơ sinh viên vừa nộp -> Tải CV ứng viên -> Cập nhật trạng thái thành "Đã xem xét" / "Đã nhận".
3. **Kiểm thử Bảo vệ Định tuyến (Route Guard):** Trong khi đang đăng nhập bằng tài khoản Sinh viên, hãy thử nhập đường dẫn trực tiếp trên thiết bị (hoặc trình duyệt) vào trang `/recruiter/post-job`. Hệ thống GoRouter sẽ tự động chặn lại, điều hướng sinh viên về trang Profile và đưa ra cảnh báo "Không có quyền truy cập dành cho nhà tuyển dụng".

---

##  Cấu hình Linh hoạt (`lib/core/config/app_config.dart`)
Bạn có thể dễ dàng thay đổi cài đặt vận hành của ứng dụng tại [app_config.dart](file:///d:/student_job_app_full_project/lib/core/config/app_config.dart):
* `useFirebase`: Thiết lập thành `true` để sử dụng dữ liệu trực tiếp trên Firebase Cloud, hoặc `false` để sử dụng bộ nhớ cục bộ offline.
* `enableJobsApi`: Thiết lập thành `true` để ứng dụng thử nghiệm tải thêm tin tuyển dụng từ API máy chủ bên thứ ba.
* `jobsBaseUrl` / `jobsPath`: Đường dẫn API lấy tin tuyển dụng bên ngoài.
