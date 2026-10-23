import 'package:flutter/material.dart';

class AsyncError extends StatelessWidget {
  const AsyncError({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, size: 48), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12), FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
        ]),
      ));
}

Widget courseImage(String url, {double height = 180}) => Image.network(
      url, height: height, width: double.infinity, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(height: height, color: Colors.black12,
          child: const Center(child: Icon(Icons.school_outlined, size: 48))),
      loadingBuilder: (context, child, progress) => progress == null ? child : Container(height: height,
          color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
    );
