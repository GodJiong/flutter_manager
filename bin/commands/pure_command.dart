import 'export_command.dart';

/// FileName clean
///
/// @Author wangjiong
/// @Date 2022/10/18
///
/// @Description: clean command
class PureCommand extends BaseCommand {
  factory PureCommand() => _instance;

  PureCommand._internal();

  static late final PureCommand _instance = PureCommand._internal();

  @override
  Future<void> run([String? commands]) async {
    await DeleteCommand().run();
    await CleanCommand().run();
    await GetCommand().run();
    return super.run();
  }

  @override
  String get description => "run delete clean and pub get in order";

  @override
  String get name => "pure";

  @override
  List<String> get aliases => ["p"];
}
