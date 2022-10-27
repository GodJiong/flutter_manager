import 'dart:io';

import 'package:path/path.dart' as p;

import 'base_command.dart';

/// FileName customer_command
///
/// @Author wangjiong
/// @Date 2022/10/21
///
/// @Description: custom command
class CustomCommand extends BaseCommand {
  String? _name;
  List<String>? _aliases;
  String? _command;

  CustomCommand({String? name, List<String>? aliases, String? command})
      : _name = name,
        _aliases = aliases,
        _command = command;

  @override
  String get description => "run a custom command or its own script";

  @override
  String get name => _name ?? "custom";

  @override
  List<String> get aliases => _aliases ?? super.aliases;

  @override
  Future<void> run([String? commands]) async {
    final results = argResults?.rest;
    // run through its own script
    if (results?.length == 1 && FileSystemEntity.isFileSync(results!.single)) {
      final path = results.single;
      final process =
          await Process.start(p.extension(path).substring(1), [path]);

      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);

      await process.exitCode;

      process.kill();
      return;
    }
    // run custom command by shell
    return super.run(commands ?? _command ?? results?.join(" "));
  }
}
