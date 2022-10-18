import 'command.dart';

/// FileName clean
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: clean命令
class CleanCommand extends Command {
  factory CleanCommand() => _instance;

  CleanCommand._internal();

  static late final CleanCommand _instance = CleanCommand._internal();

  // 命令
  final String command = """
    flutter clean
  """;

  @override
  Future<void> run([String? commands]) {
    return super.run(commands ?? command);
  }
}
