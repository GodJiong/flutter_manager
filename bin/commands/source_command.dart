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
/// 3. 遍历dependencies，依赖方式改为path方式
/// 4. 将修改完后的内容转化为新的yaml结构并覆盖原始pubspec.yaml文件
/// 5. 执行`power_command pure` 拉取最新的包依赖
/// 当前项目的snapshot快照路径
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
    final snapshotPath = getSnapshotPath(basenameWithoutExtension(current));
    // 确保重复操作
    if (File(snapshotPath).existsSync()) {
      print("please run 'power_command source restore' first!!!");
      return super.run(commands);
    }
    stdout.writeln("===========源码配置开始===============");
    // 复制pubspec.yaml文件内容到一个新的snapshot.yaml文件
    File pubFile = File('pubspec.yaml');
    if (!pubFile.existsSync()) {
      print("no pubspec.yaml!!!");
      return super.run(commands);
    }
    pubFile.copySync(snapshotPath);

    // 读取pubspec.yaml文件转化内容为map
    String yamlText = pubFile.readAsStringSync();
    // loadYaml()加载返回的是 unmodifiable Map，所以需要转一下
    Map yaml = Map.of(loadYaml(yamlText));

    // 找到源码的配置项目
    Map? sourceConfig = yaml['source_config'];
    Map? originUnique = sourceConfig?["unique"];
    // 至少保证unique是有配置的，否则直接退出
    if (originUnique == null || originUnique.isEmpty) {
      return super.run(commands);
    }

    // 全局module配置
    Map? global = sourceConfig?["global"];
    // 单一module配置
    Map unique = Map.of(originUnique);

    // 执行全局配置
    buildGlobalYaml(global, unique, yaml);

    // 执行单一配置
    bool hasUniqueActive = buildUniqueYaml(yaml, unique, pubFile);

    // 执行`power_command pure` 拉取最新的包依赖
    if (hasUniqueActive) {
      await PureCommand().run();
    }
    stdout.writeln("===========源码配置结束===============");
    return super.run(commands);
  }

  /// 执行全局配置
  void buildGlobalYaml(Map? global, Map unique, Map parentYaml) {
    if (global == null || global.isEmpty) {
      return;
    }
    // 遍历unique，检查是否依赖激活的global配置
    for (var key in unique.keys) {
      final path = unique[key]?["path"];
      // path 未配置则直接跳过，开始下一轮循环
      if (path == null) {
        continue;
      }
      // pubspec.yaml不存在则直接跳过，开始下一轮循环
      final pubFile = File(join(path, 'pubspec.yaml'));
      if (!pubFile.existsSync()) {
        continue;
      }
      // 读取pubspec.yaml文件找到dependencies并遍历
      String yamlText = pubFile.readAsStringSync();
      Map yaml = Map.of(loadYaml(yamlText));
      Map dependencies = Map.of(yaml['dependencies']);
      // 标记当前module是否用到了激活的global配置
      bool hasGlobalActive = false;
      for (var key in dependencies.keys) {
        if (global.containsKey(key) && global[key]?["active"] == true) {
          // 修改依赖方式
          dependencies[key] = {"path": global[key]?["path"]};
          hasGlobalActive = true;
        }
      }
      // 不存在dependencies变化则直接跳过，开始下一轮循环
      if (!hasGlobalActive) {
        continue;
      }
      // 为每一个源码项目原pubspec.yaml保存一个snapshot快照
      final snapshotPath = getSnapshotPath(basenameWithoutExtension(path));
      pubFile.copySync(snapshotPath);
      // 更新dependencies内容并写到pubspec.yaml
      yaml["dependencies"] = dependencies;
      // 激活对应unique的active，为后面unique build做准备
      Map uniqueValue = Map.of(unique[key]);
      uniqueValue["active"] = true;
      unique[key] = uniqueValue;
      // 重新复写pubspec.yaml文件
      writeYaml(yaml, pubFile);
    }
    // 将更新后的unique写入壳yaml
    Map sourceConfig = Map.of(parentYaml['source_config']);
    sourceConfig["unique"] = unique;
    parentYaml['source_config'] = sourceConfig;
  }

  /// 执行单一配置
  bool buildUniqueYaml(Map yaml, Map unique, File pubFile) {
    // loadYaml()加载返回的子集也是 unmodifiable Map
    Map dependencies = Map.of(yaml['dependencies']);
    // 标记当前module是否用到了激活的unique配置
    bool hasUniqueActive = false;
    unique.forEach((key, value) {
      final active = value?["active"];
      final path = value?["path"];
      if (active == true && path != null) {
        // 修改依赖方式
        dependencies[key] = {"path": path};
        hasUniqueActive = true;
      }
    });

    // 不存在dependencies变化则退出
    if (!hasUniqueActive) {
      return false;
    }
    // 更新dependencies节点
    yaml["dependencies"] = dependencies;
    // 重新复写pubspec.yaml文件
    writeYaml(yaml, pubFile);
    return true;
  }

  /// 重新复写pubspec.yaml文件
  void writeYaml(Map yaml, File pubFile) {
    var yamlWriter = YAMLWriter();
    // 转化为yaml格式字符串
    var yamlDoc = yamlWriter.write(yaml);
    pubFile.writeAsString(yamlDoc);
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
    stdout.writeln("===========恢复配置开始===============");
    // 恢复unique配置的的pubspec.yaml
    restoreUniqueYaml();
    // 恢复global配置的的pubspec.yaml
    restoreGlobalYaml();
    stdout.writeln("===========恢复配置结束===============");
    return super.run(commands);
  }

  /// 恢复unique配置的的pubspec.yaml
  void restoreUniqueYaml() {
    final snapshotPath = getSnapshotPath(basenameWithoutExtension(current));
    File snapshotFile = File(snapshotPath);
    if (snapshotFile.existsSync()) {
      snapshotFile.copySync("pubspec.yaml");
      snapshotFile.deleteSync();
    }
  }

  /// 恢复global配置的的pubspec.yaml
  void restoreGlobalYaml() {
    File pubFile = File('pubspec.yaml');
    if (!pubFile.existsSync()) {
      print("no pubspec.yaml!!!");
      return;
    }
    String yamlText = pubFile.readAsStringSync();
    Map yaml = loadYaml(yamlText);
    Map? unique = yaml['source_config']?["unique"];
    if (unique == null || unique.isEmpty) {
      return;
    }
    // 循环遍历unique找到找到每个snapshot快照并恢复对应的pubspec.yaml
    for (var key in unique.keys) {
      final path = unique[key]?["path"];
      // path 未配置则直接跳过，开始下一轮循环
      if (path == null) {
        continue;
      }
      final snapshotPath = getSnapshotPath(basenameWithoutExtension(path));
      File snapshotFile = File(snapshotPath);
      if (snapshotFile.existsSync()) {
        snapshotFile.copySync(join(path, 'pubspec.yaml'));
        snapshotFile.deleteSync();
      }
    }
    ;
  }
}

/// 生成snapshot文件路径
String getSnapshotPath(String name) {
  return join(Directory.systemTemp.path, "${name}_snapshot.yaml");
}
