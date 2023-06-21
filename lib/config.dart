import 'package:flutter_manager/util/print.dart';

/// FileName config
///
/// @Author wangjiong
/// @Date 2023/5/29
///
/// @Description: 项目统一配置

class Config {
  factory Config() => _instance;

  Config._internal();

  static late final Config _instance = Config._internal();

  /// 初始化日志
  initPrint({bool enable = true}) {
    GLOBAL_PRINT_ENABLE = enable;
  }
}
