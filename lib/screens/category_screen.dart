import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/async_state.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> _categories = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() { _loading = true; _error = null; }); try { final rows = await api.getCategories(); if (mounted) setState(() { _categories = rows; _loading = false; }); } catch (e) { if (mounted) setState(() { _error = '$e'; _loading = false; }); } }
  Future<void> _edit([Category? category]) async {
    final name = TextEditingController(text: category?.name ?? ''), description = TextEditingController(text: category?.description ?? '');
    final key = GlobalKey<FormState>();
    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text(category == null ? 'Thêm danh mục' : 'Sửa danh mục'), content: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [TextFormField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Tên *'), validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên danh mục.' : null), const SizedBox(height: 12), TextFormField(controller: description, decoration: const InputDecoration(labelText: 'Mô tả'), minLines: 2, maxLines: 4)])), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')), FilledButton(onPressed: () { if (key.currentState!.validate()) Navigator.pop(ctx, true); }, child: const Text('Lưu'))]));
    final nameValue = name.text.trim(), descriptionValue = description.text.trim();
    name.dispose(); description.dispose();
    if (result != true) return;
    final item = Category(id: category?.id ?? '', name: nameValue, description: descriptionValue);
    try { if (category == null) { await api.createCategory(item); } else { await api.updateCategory(item); } _load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }
  Future<void> _delete(Category category) async {
    try {
      final courses = await api.getCourses();
      if (courses.any((course) => course.categoryId == category.id)) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể xóa: vẫn còn khóa học thuộc danh mục này.'))); return; }
      final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Xóa danh mục?'), content: Text('Xóa "${category.name}"?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa'))]));
      if (yes != true) return;
      await api.deleteCategory(category.id); _load();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Quản lý danh mục')), floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Thêm danh mục')),
    body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? AsyncError(message: _error!, onRetry: _load) : _categories.isEmpty ? const Center(child: Text('Chưa có danh mục.')) : RefreshIndicator(onRefresh: _load, child: ListView.builder(padding: const EdgeInsets.only(bottom: 90), itemCount: _categories.length, itemBuilder: (context, i) { final c = _categories[i]; return ListTile(title: Text(c.name), subtitle: c.description.isEmpty ? null : Text(c.description), leading: const CircleAvatar(child: Icon(Icons.category_outlined)), trailing: Wrap(children: [IconButton(tooltip: 'Sửa', onPressed: () => _edit(c), icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: 'Xóa', onPressed: () => _delete(c), icon: const Icon(Icons.delete_outline))])); })));
}
