import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/core_providers.dart';
import 'design/theme.dart';
import 'routing/app_router.dart';
import 'shared/widgets/ms_toast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent system bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MySerialApp()));
}

class MySerialApp extends ConsumerWidget {
  const MySerialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'MySerial',
      debugShowCheckedModeBanner: false,
      theme: MySerialTheme.lightTheme,
      darkTheme: MySerialTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MsToastOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
