import 'dart:io';

import 'package:args/command_runner.dart';

import 'commands/export_command.dart';

/// FileName power_command
///
/// @Author wangjiong
/// @Date 2022/10/17
///
/// @Description: run脚本入口
void main(List<String> args) async {
  final runner =
      CommandRunner('power_command', 'A useful command line tool for Dart')
        ..addCommand(DeleteCommand())
        ..addCommand(CleanCommand())
        ..addCommand(PubGetCommand())
        ..addCommand(PureCommand());
  await runner.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}
