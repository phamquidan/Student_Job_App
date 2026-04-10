# Student Job App

## Tính năng hiện có

- Login/Register UI
- Home + danh sách việc làm
- Search & Filter
- Job Detail
- Favorites
- Applied Jobs (khung)
- Profile/CV (khung)
- Recruiter screens (khung)
- Dữ liệu thủ công từ `assets/data/jobs_seed.json`
- Repository sẵn hướng tích hợp API và Firebase

## Chạy ngay

```bash
flutter pub get
flutter run
```

## Bật API thật

Sửa file:

- `lib/core/config/app_config.dart`
- `lib/features/jobs/data/job_api_service.dart`

## Bật Firebase

1. Tạo project Firebase
2. Chạy:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

3. Đổi `AppConfig.useFirebase = true`
