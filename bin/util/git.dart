import '../commands/custom_command.dart';

/// FileName git
///
/// @Author wangjiong
/// @Date 2023/5/29
///
/// @Description: git相关操作
class Git {
  factory Git() => _instance;

  Git._internal();

  static late final Git _instance = Git._internal();

  /// git clone
  clone(String url, String path, String ref) async {
    final git = " git clone $url $path -b $ref";
    await CustomCommand().run(git);
  }
}
