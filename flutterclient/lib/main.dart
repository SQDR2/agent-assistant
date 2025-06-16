import 'package:flutter/material.dart' hide MenuItem;
import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io'
    show
        Platform,
        exit,
        Process,
        ProcessInfo; // Changed back to show Platform if only Platform is needed.
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart'; // 添加这行导入

import 'providers/chat_provider.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/splash_screen.dart';
import 'config/app_config.dart';
import 'services/service_manager.dart';
// import 'services/window_service.dart'; // Removed as bitsdojo_window will handle window management

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // 启动服务器
  try {
    await ServiceManager().startServer();
  } catch (e) {
    print('Failed to start server: $e');
  }

  // Initialize window service for desktop platforms
  // await WindowService().initialize(); // Removed

  runApp(const AgentAssistantApp());

  doWhenWindowReady(() async {
    final initialSize = const Size(1000, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;

    // 设置窗口图标和标题
    if (Platform.isWindows) {
      await windowManager.setIcon('assets/app_icon.ico');
    } else if (Platform.isLinux) {
      await windowManager.setIcon('assets/app_icon.png');
    }
    await windowManager.setTitle('agent-assistant');

    appWindow.show();
  });
}

class AgentAssistantApp extends StatefulWidget {
  const AgentAssistantApp({super.key});

  @override
  State<AgentAssistantApp> createState() => _AgentAssistantAppState();
}

class _AgentAssistantAppState extends State<AgentAssistantApp>
    implements WindowListener {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  late final List<MenuItemBase> _menuItems;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    Future.microtask(() async {
      await windowManager.setPreventClose(true);
      await _initSystemTray();
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initSystemTray() async {
    String path =
        Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';
    await _systemTray.initSystemTray(title: "Agent Assistant", iconPath: path);
    _menuItems = [
      MenuItem(label: '显示窗口', onClicked: () => _appWindow.show()),
      MenuItem(label: '隐藏窗口', onClicked: () => _appWindow.hide()),
      MenuItem(
          label: '退出应用',
          onClicked: () async {
            try {
              await ServiceManager().stopServer();
              await windowManager.destroy();
              exit(0);
            } catch (e) {
              print('Error during shutdown: $e');
              exit(1);
            }
          }),
    ];
    await _systemTray.setContextMenu(_menuItems);
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == 'click') {
        Platform.isWindows ? _appWindow.show() : _systemTray.popUpContextMenu();
      } else if (eventName == 'right-click') {
        Platform.isWindows ? _systemTray.popUpContextMenu() : _appWindow.show();
      }
    });
  }

  @override
  void onWindowMinimize() {}
  @override
  void onWindowRestore() {}
  @override
  void onWindowMaximize() {}
  @override
  void onWindowUnmaximize() {}
  @override
  void onWindowFocus() {}
  @override
  void onWindowBlur() {}
  @override
  void onWindowResize() {}
  @override
  void onWindowResized() {}
  @override
  void onWindowMove() {}
  @override
  void onWindowMoved() {}
  @override
  void onWindowEnterFullScreen() {}
  @override
  void onWindowLeaveFullScreen() {}
  @override
  void onWindowDocked() {}
  @override
  void onWindowUndocked() {}
  @override
  void onWindowEvent(String eventName) {}
  @override
  void onWindowClose() async {
    // Note: windowManager and bitsdojo_window both exist. We are using windowManager for 'isPreventClose'
    // and bitsdojo_window for 'hide' and 'close'.
    // If only one is desired, consolidate the window management.
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      appWindow.hide();
    } else {
      await ServiceManager().stopServer();
      appWindow.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        title: AppConfig.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/chat': (context) => const ChatScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
