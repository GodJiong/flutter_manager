import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_manager/config.dart';

import 'commands/export_command.dart';

/// FileName manager
///
/// @Author wangjiong
/// @Date 2022/10/17
///
/// @Description: main entrance
void main(List<String> args) async {
  // 统一初始化项目配置
  Config()..initPrint(enable: false);
  // 配置命令
  final runner = CommandRunner('manager', 'A useful command line tool for Flutter')
    ..addCommand(FormatCommand())
    ..addCommand(CustomCommand())
    ..addCommand(DeleteCommand())
    ..addCommand(CleanCommand())
    ..addCommand(PubGetCommand())
    ..addCommand(MVMCommand())
    ..addCommand(PureCommand());
  await runner.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}
