import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  Process? _serverProcess;
  final _logger = Logger('ServiceManager');

  factory ServiceManager() {
    return _instance;
  }

  ServiceManager._internal() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> startServer() async {
    if (_serverProcess != null) {
      _logger.info('Server is already running');
      return;
    }

    try {
      final serverPath = _getServerPath();
      _logger.info('Starting server from: $serverPath');

      _serverProcess = await Process.start(
        serverPath,
        [],
        mode: ProcessStartMode.detached,
      );

      _logger.info('Server started with PID: ${_serverProcess?.pid}');

      // 监听服务器进程的输出
      _serverProcess?.stdout.transform(utf8.decoder).listen((data) {
        _logger.info('Server stdout: $data');
      });

      _serverProcess?.stderr.transform(utf8.decoder).listen((data) {
        _logger.severe('Server stderr: $data');
      });

      // 监听服务器进程的退出
      _serverProcess?.exitCode.then((code) {
        _logger.info('Server process exited with code: $code');
        _serverProcess = null;
      });
    } catch (e) {
      _logger.severe('Failed to start server: $e');
      rethrow;
    }
  }

  Future<void> stopServer() async {
    if (_serverProcess == null) {
      _logger.info('Server is not running');
      return;
    }

    try {
      _serverProcess?.kill();
      await _serverProcess?.exitCode;
      _serverProcess = null;
      _logger.info('Server stopped');
    } catch (e) {
      _logger.severe('Failed to stop server: $e');
      rethrow;
    }
  }

  String _getServerPath() {
    final executableName =
        Platform.isWindows ? 'agentassistant-srv.exe' : 'agentassistant-srv';
    final currentDir = Directory.current.path;
    return path.join(currentDir, executableName);
  }
}
