import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/api_service.dart';
import '../widgets/async_state.dart';
import 'course_form_screen.dart';
import 'trailer_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.course});
  final Course course;
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  String? _category, _error;
  @override
  void initState() { super.initState(); _loadCategory(); }
  Future<void> _loadCategory() async {
    try { final categories = await api.getCategories(); final matches = categories.where((c) => c.id == widget.course.categoryId); if (mounted) setState(() => _category = matches.isEmpty ? 'Chưa phân loại' : matches.first.name); }
    catch (e) { if (mounted) setState(() => _error = '$e'); }
  }
  Future<void> _delete() async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Xóa khóa học?'), content: Text('Xóa "${widget.course.title}"?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa'))]));
    if (yes != true) return;
    try { await api.deleteCourse(widget.course.id); if (mounted) Navigator.pop(context); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }
  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết khóa học'),
        actions: [IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline))],
      ),
      body: ListView(
        children: [
          courseImage(c.thumbnail, height: 240),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                _line('Giảng viên', c.instructor),
                _line('Danh mục', _category ?? (_error ?? 'Đang tải…')),
                _line('Học phí', '${c.price.toStringAsFixed(0)} ₫'),
                _line('Thời lượng', c.duration),
                _line('Ngày tạo', c.createdAt),
                const SizedBox(height: 10),
                Text('Mô tả', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(c.description),
                if (c.trailerUrl.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TrailerScreen(url: c.trailerUrl)),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Xem trailer'),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseFormScreen(course: c)));
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Sửa khóa học'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _line(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 105, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))), Expanded(child: Text(value))]));
}
