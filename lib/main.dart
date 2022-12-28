import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '倾音悦',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const HomePage(),
      getPages: [
        GetPage(name: "/", page: () => const HomePage()),
        GetPage(name: "/song", page: () => const SongPage()),
        GetPage(name: "/playlist", page: () => const PlaylistPage()),
      ],
    );
  }
}
