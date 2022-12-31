import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qingyin_music/page_manager.dart';
import 'package:qingyin_music/services/service_locator.dart';
import 'pages/pages.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '倾音悦',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
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
