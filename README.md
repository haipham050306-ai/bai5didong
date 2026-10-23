# Course Manager (Flutter + MockAPI)

Ứng dụng CRUD khóa học và danh mục bằng Flutter. Danh mục được tải từ API và liên kết qua `categoryId`; không có tên danh mục hardcode.

## Cấu hình MockAPI

Tạo project MockAPI với hai resource đúng tên `categories` và `courses`. Các trường đề xuất:

- `categories`: `name` (string), `description` (string)
- `courses`: `title`, `description`, `categoryId`, `instructor`, `price` (number), `duration`, `thumbnail`, `trailerUrl`, `createdAt`

Ứng dụng đọc ID do MockAPI sinh tự động. Truyền URL gốc của API (không thêm `/courses` hay `/categories`) lúc chạy:

```sh
flutter pub get
flutter run --dart-define=MOCKAPI_BASE_URL=https://YOUR_PROJECT_ID.mockapi.io/api/v1
```

Có thể đặt giá trị này làm Dart define trong cấu hình build/release. Không commit URL chứa token riêng tư nếu project của bạn bật xác thực.

## Chạy ứng dụng

Mở thư mục trong Flutter SDK project (hoặc tạo platform runner bằng `flutter create .` nếu checkout chỉ có thư mục `lib`), sau đó chạy lệnh ở trên. Android và iOS cần quyền truy cập Internet; HTTPS được dùng cho API, ảnh và video.

## Cấu trúc

```text
lib/
  main.dart
  models/       category.dart, course.dart
  services/     api_service.dart (GET/POST/PUT/DELETE)
  screens/      course_list_screen.dart, course_detail_screen.dart,
                course_form_screen.dart, category_screen.dart, trailer_screen.dart
  widgets/      async_state.dart
```

Trailer dùng `video_player` và yêu cầu URL video MP4 có thể truy cập trực tiếp. Danh sách hỗ trợ tìm kiếm, lọc danh mục, trạng thái tải/lỗi/rỗng; form kiểm tra dữ liệu bắt buộc và học phí không âm. Xóa danh mục bị chặn khi API vẫn trả về khóa học tham chiếu `categoryId` đó.
