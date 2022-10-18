import 'command.dart';

/// FileName pub_get_command
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: pub get命令
class PubGetCommand extends Command {
  factory PubGetCommand() => _instance;

  PubGetCommand._internal();

  static late final PubGetCommand _instance = PubGetCommand._internal();

  // 命令
  final String command = """
    flutter pub get
  """;

  @override
  Future<void> run([String? commands]) {
    return super.run(commands ?? command);
  }
}
