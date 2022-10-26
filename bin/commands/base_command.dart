import 'dart:io';

import 'package:args/command_runner.dart';

/// FileName base_command
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: command base
abstract class BaseCommand extends Command {
  BaseCommand() {
    // add format flag
    argParser.addFlag("format",
        abbr: "f",
        defaultsTo: false,
        negatable: false,
        help: "format all code");
  }

  /// run sh script
  @override
  Future<void> run([String? commands]) async {
    // parse flag and option
    if (argResults?["format"] == true) {
      commands = """
    ${commands ?? ""}
    dart format .
    """;
    }

    if (commands == null || commands.trim().isEmpty) {
      return;
    }

    print("========run $commands==========");

    final tmp = File(
        "${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.sh");

    tmp.writeAsStringSync(commands);

    final process = await Process.start("sh", [tmp.path]);

    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    await process.exitCode;

    process.kill();
    tmp.deleteSync();
  }
}
