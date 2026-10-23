import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/course.dart';
import '../services/api_service.dart';
import '../widgets/async_state.dart';

class CourseFormScreen extends StatefulWidget {
  const CourseFormScreen({super.key, this.course});
  final Course? course;
  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(), _description = TextEditingController(), _instructor = TextEditingController(), _price = TextEditingController(), _duration = TextEditingController(), _thumbnail = TextEditingController(), _trailer = TextEditingController();
  List<Category> _categories = [];
  String? _categoryId, _loadError;
  bool _loading = true, _saving = false;
  bool get _editing => widget.course != null;
  @override
  void initState() { super.initState(); final c = widget.course; if (c != null) { _title.text = c.title; _description.text = c.description; _instructor.text = c.instructor; _price.text = c.price.toString(); _duration.text = c.duration; _thumbnail.text = c.thumbnail; _trailer.text = c.trailerUrl; _categoryId = c.categoryId; } _load(); }
  Future<void> _load() async { try { final cats = await api.getCategories(); if (mounted) setState(() { _categories = cats; _loading = false; if (!_categories.any((c) => c.id == _categoryId)) _categoryId = null; }); } catch (e) { if (mounted) setState(() { _loadError = '$e'; _loading = false; }); } }
  @override
  void dispose() { for (final c in [_title, _description, _instructor, _price, _duration, _thumbnail, _trailer]) { c.dispose(); } super.dispose(); }
  String? _required(String? v) => v == null || v.trim().isEmpty ? 'Trường này bắt buộc.' : null;
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_categoryId == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục.'))); return; }
    setState(() => _saving = true);
    final old = widget.course;
    final item = Course(id: old?.id ?? '', title: _title.text.trim(), description: _description.text.trim(), categoryId: _categoryId!, instructor: _instructor.text.trim(), price: double.parse(_price.text.trim().replaceAll(',', '.')), duration: _duration.text.trim(), thumbnail: _thumbnail.text.trim(), trailerUrl: _trailer.text.trim(), createdAt: old?.createdAt ?? DateTime.now().toIso8601String());
    try { if (_editing) { await api.updateCourse(item); } else { await api.createCourse(item); } if (mounted) Navigator.pop(context, true); }
    catch (e) { if (mounted) { setState(() => _saving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); } }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(_editing ? 'Sửa khóa học' : 'Thêm khóa học')),
    body: _loading ? const Center(child: CircularProgressIndicator()) : _loadError != null ? AsyncError(message: _loadError!, onRetry: () { setState(() { _loading = true; _loadError = null; }); _load(); }) :
      Form(key: _form, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Tên khóa học *'), validator: _required),
        const SizedBox(height: 12), TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Mô tả *'), minLines: 3, maxLines: 6, validator: _required),
        const SizedBox(height: 12), TextFormField(controller: _instructor, decoration: const InputDecoration(labelText: 'Giảng viên *'), validator: _required),
        const SizedBox(height: 12), DropdownButtonFormField<String>(value: _categoryId, decoration: const InputDecoration(labelText: 'Danh mục *'), items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => setState(() => _categoryId = v), validator: (v) => v == null ? 'Vui lòng chọn danh mục.' : null),
        const SizedBox(height: 12), TextFormField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Học phí (₫) *'), validator: (v) { final required = _required(v); if (required != null) return required; final n = double.tryParse(v!.trim().replaceAll(',', '.')); if (n == null) return 'Nhập số hợp lệ.'; if (n < 0) return 'Học phí không được âm.'; return null; }),
        const SizedBox(height: 12), TextFormField(controller: _duration, decoration: const InputDecoration(labelText: 'Thời lượng *'), validator: _required),
        const SizedBox(height: 12), TextFormField(controller: _thumbnail, onChanged: (_) => setState(() {}), keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'URL ảnh bìa *'), validator: (v) { final r = _required(v); if (r != null) return r; final uri = Uri.tryParse(v!.trim()); return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty ? null : 'URL phải bắt đầu bằng http:// hoặc https://.'; }),
        if (_thumbnail.text.trim().isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: courseImage(_thumbnail.text.trim(), height: 180))),
        const SizedBox(height: 12), TextFormField(controller: _trailer, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'URL trailer MP4 (không bắt buộc)')),
        const SizedBox(height: 24), FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save), label: Text(_saving ? 'Đang lưu…' : 'Lưu khóa học')),
      ])));
}
