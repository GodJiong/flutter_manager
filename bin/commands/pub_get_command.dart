import 'base_command.dart';

/// FileName pub_get_command
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: pub get command
class PubGetCommand extends BaseCommand {
  factory PubGetCommand() => _instance;

  PubGetCommand._internal() {
    addSubcommand(GetCommand());
  }

  static late final PubGetCommand _instance = PubGetCommand._internal();

  @override
  String get description =>
      "run flutter pub get (note: this is a parent command)";

  @override
  String get name => "pub";
}

class GetCommand extends BaseCommand {
  factory GetCommand() => _instance;

  GetCommand._internal();

  static late final GetCommand _instance = GetCommand._internal();

  final String command = "flutter pub get";

  @override
  String get description => "run $command";

  @override
  String get name => "get";

  @override
  Future<void> run([String? commands]) {
    return super.run(commands ?? command);
  }
}
