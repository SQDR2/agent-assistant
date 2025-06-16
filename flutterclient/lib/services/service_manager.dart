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

      // 检查文件是否存在
      final file = File(serverPath);
      if (!await file.exists()) {
        _logger.severe('Server executable not found at: $serverPath');
        throw Exception('Server executable not found at: $serverPath');
      }

      // 检查文件权限
      if (Platform.isLinux || Platform.isMacOS) {
        final stat = await file.stat();
        if (!stat.modeString().contains('x')) {
          _logger.severe('Server executable does not have execute permission');
          throw Exception('Server executable does not have execute permission');
        }
      }

      // 使用绝对路径启动进程
      _serverProcess = await Process.start(
        serverPath,
        [],
        mode: ProcessStartMode.detached,
        workingDirectory: path.dirname(serverPath),
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
      // 在 Linux 上使用 kill 命令强制结束进程
      if (Platform.isLinux) {
        final result =
            await Process.run('kill', ['-9', '${_serverProcess?.pid}']);
        if (result.exitCode != 0) {
          _logger.warning('Failed to kill process: ${result.stderr}');
        }
      } else {
        _serverProcess?.kill();
      }

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

    // 获取当前可执行文件的目录
    final currentDir = path.dirname(Platform.resolvedExecutable);
    _logger.info('Current executable directory: $currentDir');

    // 构建服务器路径
    final serverPath = path.join(currentDir, executableName);
    _logger.info('Server path: $serverPath');

    return serverPath;
  }
}
