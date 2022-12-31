import '../page_manager.dart';
import 'package:get_it/get_it.dart';
import 'audio_handler.dart';

GetIt getIt = GetIt.instance;

/// 初始化服务
Future<void> setupServiceLocator() async {
  getIt.registerSingleton<MyAudioHandler>(await initAudioService());

  getIt.registerLazySingleton<PageManager>(() => PageManager());
}
