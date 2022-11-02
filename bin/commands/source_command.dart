import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import 'export_command.dart';

/// FileName source_command
///
/// @Author wangjiong
/// @Date 2022/10/31
///
/// @Description: SourceCommand command

/// snapshot快照路径
final snapshot = "${Directory.systemTemp.path}/power_command_snapshot.yaml";

class SourceCommand extends BaseCommand {
  factory SourceCommand() => _instance;

  SourceCommand._internal() {
    addSubcommand(BuildCommand());
    addSubcommand(RestoreCommand());
  }

  static late final SourceCommand _instance = SourceCommand._internal();

  @override
  String get description => "run source depended";

  @override
  String get name => "source";

  @override
  List<String> get aliases => ["s"];
}

/// 编译命令 power_command source build
/// 1. 复制pubspec.yaml文件内容到一个新的snapshot.yaml文件
/// 2. 读取pubspec.yaml文件转化内容为map
/// 3. 遍历dependencies，git依赖方式改为path方式
/// 4. 将修改完后的内容转化为新的yaml结构并覆盖原始pubspec.yaml文件
/// 5. 执行`power_command pure` 拉取最新的包依赖
class BuildCommand extends BaseCommand {
  factory BuildCommand() => _instance;

  BuildCommand._internal();

  static late final BuildCommand _instance = BuildCommand._internal();

  @override
  String get description => "run local path depended";

  @override
  String get name => "build";

  @override
  List<String> get aliases => ["b"];

  @override
  Future<void> run([String? commands]) async {
    if (await File(snapshot).exists()) {
      print("please run 'power_command source restore' first!!!");
      return;
    }
    // 复制pubspec.yaml文件内容到一个新的snapshot.yaml文件
    String pubPath = join(Directory.current.path, 'pubspec.yaml');
    File pubFile = File(pubPath);
    pubFile.copySync(snapshot);

    // 读取pubspec.yaml文件转化内容为map
    String yamlText = pubFile.readAsStringSync();
    // loadYaml()加载返回的是 unmodifiable Map
    Map yaml = Map.of(loadYaml(yamlText));
    // 是否存在源码依赖
    bool sourceExists = false;
    // loadYaml()加载返回的子集也是 unmodifiable Map
    Map dependencies = Map.of(yaml['dependencies']);

    // 遍历dependencies
    dependencies.forEach((key, value) {
      // source为bool属性，代表是否为源码依赖
      final source = value?["git"]?["source"];
      // source_path为String属性，代表源码路径
      final sourcePath = value?["git"]?["source_path"];
      if (source == true || sourcePath != null) {
        // 修改依赖方式
        dependencies[key] = {"path": sourcePath};
        sourceExists = true;
      }
    });
    // 存在源码依赖方式才进行写入
    if (sourceExists) {
      // 更新dependencies节点
      yaml["dependencies"] = dependencies;
      // 转化为yaml格式字符串
      var yamlWriter = YAMLWriter();
      var yamlDoc = yamlWriter.write(yaml);
      // 重新复写pubspec.yaml文件
      pubFile.writeAsString(yamlDoc);
    }
    // 执行`power_command pure` 拉取最新的包依赖
    await PureCommand().run();
    return super.run(commands);
  }
}

/// 恢复命令 power_command source restore
/// 1. 读取snapshot.yaml文件内容覆盖pubspec.yaml
/// 2. 删除snapshot.yaml文件
class RestoreCommand extends BaseCommand {
  factory RestoreCommand() => _instance;

  RestoreCommand._internal();

  static late final RestoreCommand _instance = RestoreCommand._internal();

  @override
  String get description => "run restore pubspec.yaml";

  @override
  String get name => "restore";

  @override
  List<String> get aliases => ["r"];

  @override
  Future<void> run([String? commands]) async {
    File pubFile = File(snapshot);
    pubFile.copySync("pubspec.yaml");
    pubFile.deleteSync();
    return super.run(commands);
  }
}
