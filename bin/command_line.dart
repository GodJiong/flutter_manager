import 'export_command.dart';

/// FileName command_line
///
/// @Author wangjiong
/// @Date 2022/10/17
///
/// @Description: run脚本入口
void main(List<String> args) async {
  print("=======开始执行脚本===============");
  final stream = <Command>[DeleteCommand(), CleanCommand(), PubGetCommand()];
  for (final command in stream) {
    await command.run();
  }
  print("=======脚本执行结束===============");
}
