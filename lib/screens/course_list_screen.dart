import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/course.dart';
import '../services/api_service.dart';
import '../widgets/async_state.dart';
import 'category_screen.dart';
import 'course_detail_screen.dart';
import 'course_form_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});
  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  List<Course> _courses = [];
  List<Category> _categories = [];
  bool _loading = true;
  String? _error;
  String _query = '', _category = 'all';

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final values = await Future.wait([api.getCourses(), api.getCategories()]);
      if (!mounted) return;
      setState(() { _courses = values[0] as List<Course>; _categories = values[1] as List<Category>; _loading = false; });
    } catch (e) { if (mounted) setState(() { _error = '$e'; _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _courses.where((c) => c.title.toLowerCase().contains(_query.toLowerCase()) && (_category == 'all' || c.categoryId == _category)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Khóa học'), actions: [
        IconButton(tooltip: 'Danh mục', onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen())); _load(); }, icon: const Icon(Icons.category_outlined)),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseFormScreen())); _load(); }, icon: const Icon(Icons.add), label: const Text('Thêm khóa học')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? AsyncError(message: _error!, onRetry: _load) :
        RefreshIndicator(onRefresh: _load, child: CustomScrollView(slivers: [
          if (api.isDemo) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 0), child: Card(color: Color(0xFFE8F1FF), child: Padding(padding: EdgeInsets.all(12), child: Row(children: [Icon(Icons.info_outline, color: Color(0xFF2457C5)), SizedBox(width: 10), Expanded(child: Text('Đang chạy với dữ liệu mẫu. Cấu hình MockAPI để lưu dữ liệu trực tuyến.'))]))))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Column(children: [
            TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tìm theo tên khóa học'), onChanged: (v) => setState(() => _query = v)),
            const SizedBox(height: 10), DropdownButtonFormField<String>(value: _category, decoration: const InputDecoration(labelText: 'Lọc theo danh mục'),
              items: [const DropdownMenuItem(value: 'all', child: Text('Tất cả danh mục')), ..._categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))], onChanged: (v) => setState(() => _category = v ?? 'all')),
          ]))),
          if (filtered.isEmpty) const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Không tìm thấy khóa học nào.')))
          else SliverPadding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 90), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, i) {
            final c = filtered[i];
            final matches = _categories.where((x) => x.id == c.categoryId);
            final categoryName = matches.isEmpty ? 'Chưa phân loại' : matches.first.name;
            return Card(clipBehavior: Clip.antiAlias, margin: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c))); _load(); }, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              courseImage(c.thumbnail, height: 170), Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 5),
                Text('${c.instructor}  •  $categoryName'), const SizedBox(height: 5), Text('${c.price.toStringAsFixed(0)} ₫', style: const TextStyle(fontWeight: FontWeight.bold)),
              ])),
            ])));
          }, childCount: filtered.length))),
        ])),
    );
  }
}
