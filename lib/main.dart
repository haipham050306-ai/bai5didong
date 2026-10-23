import 'package:flutter/material.dart';
import 'screens/course_list_screen.dart';

void main() => runApp(const CourseManagerApp());

class CourseManagerApp extends StatelessWidget {
  const CourseManagerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Course Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B5CCC)),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const CourseListScreen(),
      );
}
