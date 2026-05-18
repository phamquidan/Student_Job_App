# Nexus Talent — Student Job App

Ứng dụng tìm việc làm cho sinh viên, tích hợp Firebase (Auth, Firestore, Storage) và luồng nhà tuyển dụng.

## Tính năng

### Sinh viên
- Đăng ký / đăng nhập (chọn vai trò khi đăng ký)
- Duyệt việc làm (seed JSON + tin recruiter trên Firestore)
- Tìm kiếm & lọc theo nguồn, loại việc
- Chi tiết việc, yêu thích, ứng tuyển nội bộ
- Theo dõi đơn ứng tuyển kèm **trạng thái** (Đã nộp / Đang xem xét / Phỏng vấn)
- Upload & quản lý CV (Firebase Storage)

### Nhà tuyển dụng
- Đăng tin tuyển dụng
- Quản lý tin đã đăng
- Xem danh sách ứng viên, lọc theo tin, cập nhật trạng thái, xem CV

### Kỹ thuật
- Flutter + Riverpod + GoRouter
- Route guard (auth + role recruiter)
- Firestore Security Rules + Storage Rules
- Cloud Functions (`createJob`, `updateApplicationStatus`)

## Chạy app

```bash
flutter pub get
flutter run
```

Firebase đã bật mặc định (`AppConfig.useFirebase = true`). Cấu hình nằm trong `lib/firebase_options.dart`.

## Deploy Firebase

Project ID: `student-job-app-1d837` (đã cấu hình trong `.firebaserc`)

**Windows PowerShell (5.x)** — không dùng `&&`; chạy lần lượt:

```powershell
cd functions
npm install
cd ..
firebase deploy --only firestore:rules,firestore:indexes --project student-job-app-1d837
```

Hoặc một dòng với `;`:

```powershell
cd functions; npm install; cd ..
```

**Bash / PowerShell 7+** có thể dùng `cd functions && npm install && cd ..`.

**Lưu ý deploy thêm (cần thao tác trên Console):**
- **Storage rules:** bật Firebase Storage trước tại [Firebase Console → Storage](https://console.firebase.google.com/project/student-job-app-1d837/storage), sau đó chạy `firebase deploy --only storage:rules`
- **Cloud Functions:** project cần gói **Blaze**, rồi chạy `firebase deploy --only functions`

Composite indexes được khai báo trong `firestore.indexes.json`.

## Tài khoản demo gợi ý

| Vai trò | Cách tạo |
|---|---|
| Sinh viên | Đăng ký → chọn **Sinh viên** |
| Nhà tuyển dụng | Đăng ký → chọn **Nhà tuyển dụng** |

## Kịch bản demo nhanh

1. **Sinh viên:** đăng nhập → duyệt việc → ứng tuyển → upload CV → xem *Hoạt động của tôi*
2. **Recruiter:** đăng nhập → đăng tin → xem ứng viên → cập nhật trạng thái → mở CV
3. **Guard:** sinh viên thử vào `/recruiter/post-job` → bị chuyển về Profile + thông báo

## Cấu trúc chính

```
lib/
├── app/              # Router, routes
├── core/             # Theme, config, widgets dùng chung
└── features/
    ├── auth/
    ├── jobs/
    ├── favorites/
    ├── applications/
    ├── profile/
    └── recruiter/
```

## API jobs (tùy chọn)

Đặt `AppConfig.enableJobsApi = true` và cấu hình endpoint trong `lib/features/jobs/data/job_api_service.dart`.
