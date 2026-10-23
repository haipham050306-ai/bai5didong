import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/course.dart';

/// Uses MockAPI when configured; otherwise uses a seeded in-memory dataset so
/// the whole app can be previewed and CRUD tested before creating a MockAPI.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _configuredBase = String.fromEnvironment('MOCKAPI_BASE_URL');
  static const _defaultBase = 'https://YOUR_PROJECT_ID.mockapi.io/api/v1';
  String get baseUrl => (_configuredBase.isEmpty ? _defaultBase : _configuredBase).replaceAll(RegExp(r'/$'), '');
  bool get isDemo => baseUrl.contains('YOUR_PROJECT_ID');

  static final List<Category> _demoCategories = [
    const Category(id: '1', name: 'Lập trình', description: 'Lập trình ứng dụng và web'),
    const Category(id: '2', name: 'Thiết kế', description: 'Thiết kế giao diện và đồ họa'),
    const Category(id: '3', name: 'Kinh doanh', description: 'Kỹ năng kinh doanh'),
  ];
  static final List<Course> _demoCourses = [
    const Course(id: '1', title: 'Flutter từ cơ bản đến nâng cao', description: 'Xây dựng ứng dụng đa nền tảng với Flutter và Dart. Bạn sẽ thực hành tạo giao diện, kết nối API và quản lý trạng thái.', categoryId: '1', instructor: 'Nguyễn Minh', price: 499000, duration: '12 giờ', thumbnail: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1000', trailerUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', createdAt: '2026-01-10'),
    const Course(id: '2', title: 'UI/UX Design thực chiến', description: 'Nắm quy trình thiết kế sản phẩm số từ nghiên cứu đến prototype.', categoryId: '2', instructor: 'Trần Hà', price: 350000, duration: '8 giờ', thumbnail: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=1000', trailerUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', createdAt: '2026-02-12'),
    const Course(id: '3', title: 'Marketing số cho người mới', description: 'Tìm hiểu các kênh marketing số và cách xây dựng chiến dịch hiệu quả.', categoryId: '3', instructor: 'Lê Anh', price: 0, duration: '6 giờ', thumbnail: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1000', trailerUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', createdAt: '2026-03-05'),
  ];
  static int _nextId = 4;

  Uri _uri(String path) => Uri.parse('$baseUrl/$path');
  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<dynamic> _request(String method, String path, {Object? body}) async {
    final uri = _uri(path);
    late http.Response response;
    try {
      switch (method) {
        case 'GET': response = await _client.get(uri, headers: _headers); break;
        case 'POST': response = await _client.post(uri, headers: _headers, body: jsonEncode(body)); break;
        case 'PUT': response = await _client.put(uri, headers: _headers, body: jsonEncode(body)); break;
        case 'DELETE': response = await _client.delete(uri, headers: _headers); break;
        default: throw const ApiException('Phương thức API không được hỗ trợ.');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Không thể kết nối đến máy chủ: $e');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('API trả về lỗi ${response.statusCode}: ${response.body}');
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Future<List<Category>> getCategories() async => isDemo ? List.of(_demoCategories) : ((await _request('GET', 'categories')) as List).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  Future<Category> createCategory(Category value) async {
    if (isDemo) { final v = Category(id: '${_nextId++}', name: value.name, description: value.description); _demoCategories.add(v); return v; }
    return Category.fromJson(await _request('POST', 'categories', body: value.toJson()));
  }
  Future<Category> updateCategory(Category value) async {
    if (isDemo) { final i = _demoCategories.indexWhere((x) => x.id == value.id); if (i >= 0) _demoCategories[i] = value; return value; }
    return Category.fromJson(await _request('PUT', 'categories/${value.id}', body: value.toJson()));
  }
  Future<void> deleteCategory(String id) async { if (isDemo) { _demoCategories.removeWhere((x) => x.id == id); return; } await _request('DELETE', 'categories/$id'); }

  Future<List<Course>> getCourses() async => isDemo ? List.of(_demoCourses) : ((await _request('GET', 'courses')) as List).map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  Future<Course> getCourse(String id) async => isDemo ? _demoCourses.firstWhere((x) => x.id == id) : Course.fromJson(await _request('GET', 'courses/$id'));
  Future<Course> createCourse(Course value) async {
    if (isDemo) { final v = Course(id: '${_nextId++}', title: value.title, description: value.description, categoryId: value.categoryId, instructor: value.instructor, price: value.price, duration: value.duration, thumbnail: value.thumbnail, trailerUrl: value.trailerUrl, createdAt: value.createdAt); _demoCourses.add(v); return v; }
    return Course.fromJson(await _request('POST', 'courses', body: value.toJson()));
  }
  Future<Course> updateCourse(Course value) async {
    if (isDemo) { final i = _demoCourses.indexWhere((x) => x.id == value.id); if (i >= 0) _demoCourses[i] = value; return value; }
    return Course.fromJson(await _request('PUT', 'courses/${value.id}', body: value.toJson()));
  }
  Future<void> deleteCourse(String id) async { if (isDemo) { _demoCourses.removeWhere((x) => x.id == id); return; } await _request('DELETE', 'courses/$id'); }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

final api = ApiService();
