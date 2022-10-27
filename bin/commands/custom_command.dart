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
  String get description => "run a custom command";

  @override
  String get name => _name ?? "custom";

  @override
  List<String> get aliases => _aliases ?? super.aliases;

  @override
  Future<void> run([String? commands]) {
    return super.run(commands ?? _command ?? argResults?.rest.join(" "));
  }
}
