import 'dart:io';

import 'package:flutter_manager/util/print.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../../util/git.dart';
import '../export_command.dart';
import 'constant.dart';
import 'module_init_config.dart';
import 'module_tree_structure.dart';

/// FileName mvm_command
///
/// @Author wangjiong
/// @Date 2023/5/22
///
/// @Description: 组件版本管理

class MVMCommand extends BaseCommand {
  factory MVMCommand() => _instance;

  MVMCommand._internal();

  static late final MVMCommand _instance = MVMCommand._internal();

  @override
  String get description => "flutter module version manager";

  @override
  String get name => "mvm";

  @override
  List<String> get aliases => ["m"];

  @override
  Future<void> run([String? commands]) async {
    // 定义五个后面会用到的文件
    final projectPubFile = new File(PATH_PUBSPEC);
    final moduleFile = new File(PATH_MVM_MODULE);
    final versionFile = new File(PATH_MVM_VERSION);
    final delegateFile = new File(PATH_MVM_DELEGATE);
    final snapshotModuleFile = new File(PATH_MVM_SNAPSHOT_MODULE);

    // 检查根目录pubspec.yaml是否存在
    if (!projectPubFile.existsSync()) {
      print("no pubspec.yaml!!!");
      return;
    }

    // 初始化配置文件
    final initConfig = ModuleInitConfig()
      ..initModuleTemplate(moduleFile)
      ..initVersionTemplate(versionFile)
      ..initDelegateTemplate(delegateFile);

    // 如果是首次初始化则需等待用户配置之后再重新运行命令
    if (initConfig.isFirstInitialization) {
      print("==================================");
      print("首次初始化完成，请完善mvm配置后再重新执行命令......");
      print("==================================");
      return;
    }

    // 解析宿主pubspec.yaml
    String projectPubText = projectPubFile.readAsStringSync();
    Map projectPubYaml = loadYaml(projectPubText);
    String? projectName = projectPubYaml[NAME];
    if (projectName == null) {
      throw Exception("pubspec.yaml的$NAME不能为空！！！");
    }

    // 解析module配置
    String moduleText = moduleFile.readAsStringSync();
    Map moduleConfig = loadYaml(moduleText);

    // 解析version配置
    String versionText = versionFile.readAsStringSync();
    Map versionConfig = loadYaml(versionText);
    Map version = versionConfig[VERSION];

    // 解析delegate配置
    String delegateText = delegateFile.readAsStringSync();
    Map delegateConfig = loadYaml(delegateText);
    String delegatePath = delegateConfig[PATH];
    Map delegateGit = delegateConfig[GIT];

    // 解析module快照
    Map snapshotModuleConfig = {};
    bool snapshotModuleExists = snapshotModuleFile.existsSync();
    if (snapshotModuleExists) {
      String snapshotModuleText = snapshotModuleFile.readAsStringSync();
      snapshotModuleConfig = loadYaml(snapshotModuleText);
    }

    /// 初始化本地源码文件夹
    _initLocalDelegatePathDir(String path) {
      final pathDir = new Directory(path);
      if (!pathDir.existsSync()) {
        pathDir.createSync(recursive: true);
      }
    }

    /// 根据当前module配置更新模块
    _updateBasedModuleFile() async {
      for (MapEntry e in moduleConfig.entries) {
        final currentModuleName = e.key;
        // 定义当前组件的pubspec文件，用于写入后续的库版本
        final localPath = "$delegatePath/$currentModuleName";
        File currentPubFile = File("$localPath/$PATH_PUBSPEC");
        // 通过宿主工程pubspec.yaml的"name"属性判断module是否为宿主工程，如果不是且本地没下载则需要克隆
        if (currentModuleName == projectName) {
          currentPubFile = projectPubFile;
        } else if (!currentPubFile.existsSync()) {
          final url = delegateGit[currentModuleName][GIT][URL];
          final ref = delegateGit[currentModuleName][GIT][REF];
          await Git().clone(url, localPath, ref);
        }
        // 进入yaml文件编辑模式
        String currentPubText = currentPubFile.readAsStringSync();
        final currentPubEditor = YamlEditor(currentPubText);
        // 区分不同依赖方式
        Object? value;
        // 遍历当前组件的依赖库列表，匹配对应的版本号
        for (String dependency in e.value[DEPENDENCIES]) {
          // 依赖库依赖方式
          final v = version[dependency];
          switch (v) {
            case GIT:
              // 设置对应的git地址
              value = {GIT: delegateGit[dependency]?[GIT]};
              break;
            case PATH:
              // 设置对应的源码地址
              String currentChildModuleLocalPath = "../$dependency";
              if (currentModuleName == projectName) {
                currentChildModuleLocalPath = "$delegatePath/$dependency";
              }
              value = {PATH: currentChildModuleLocalPath};
              break;
            case null:
              throw Exception("$dependency未在version.yaml文件中注册");
            // 带版本号的
            default:
              value = v;
          }
          // 更新对应的结点（新增的三方库会追加到末尾）
          currentPubEditor.update([DEPENDENCIES, dependency], value);
        }
        // 写入更新后的YAML文件
        var currentYamlString = currentPubEditor.toString();
        currentPubFile.writeAsStringSync(currentYamlString);
      }
    }

    /// 当快照存在时，以快照为准移除当前版本不用的三方库
    _removeBasedSnapshotFile() {
      if (!snapshotModuleExists) {
        return;
      }
      for (MapEntry e in snapshotModuleConfig.entries) {
        final currentModuleName = e.key;
        // 找到共有的业务组件
        if (!moduleConfig.containsKey(currentModuleName)) {
          continue;
        }
        // 定义当前组件的pubspec文件，用于写入后续的操作
        final localPath = "$delegatePath/$currentModuleName";
        File currentPubFile = File("$localPath/$PATH_PUBSPEC");
        // 宿主工程的pub路径不同
        if (currentModuleName == projectName) {
          currentPubFile = projectPubFile;
        }
        // 进入yaml文件编辑模式
        String currentPubText = currentPubFile.readAsStringSync();
        final currentPubEditor = YamlEditor(currentPubText);
        // 遍历业务组件所依赖的三方库列表
        for (String dependency in e.value[DEPENDENCIES]) {
          // 找到快照有而当前版本没有的三方库
          List currentDependencies = moduleConfig[currentModuleName][DEPENDENCIES];
          if (currentDependencies.contains(dependency)) {
            continue;
          }
          // 移除不用的三方库
          currentPubEditor.remove([DEPENDENCIES, dependency]);
        }
        // 写入更新后的YAML文件
        var currentYamlString = currentPubEditor.toString();
        currentPubFile.writeAsStringSync(currentYamlString);
      }
    }

    /// 匹配所有的组件版本
    _matchAllModuleVersion() async {
      // 1. 初始化本地源码文件夹
      _initLocalDelegatePathDir(delegatePath);
      // 2. 无论快照存不存在，都以当前版本为准正常回溯更新
      await _updateBasedModuleFile();
      // 3. 当快照存在时，以快照为准移除当前版本不用的三方库
      _removeBasedSnapshotFile();
    }

    /// 更新依赖方式
    _update(ModuleTreeNode root, String targetModule, String delegate, Map realProjectModule) {
      // 查找从节点到根节点的所有路径
      List<List<String>> result = findNodePathsToRoot(root, targetModule);
      // 中相邻子父节点对
      for (var path in result) {
        for (var i = 0; i < path.length - 1; i++) {
          final parentModule = path[i + 1];
          final childModule = path[i];
          File pubFile = File("$delegatePath/$parentModule/$PATH_PUBSPEC");
          // 区分宿主工程的pubspec.yaml文件位置
          if (parentModule == projectName) {
            pubFile = projectPubFile;
          }
          String pubText = pubFile.readAsStringSync();
          // 区分不同依赖方式
          Object? value;
          switch (delegate) {
            // 切换远程模式
            case GIT:
              value = delegateGit[childModule];
              break;
            // 切换源码模式
            case PATH:
              // 当前子module源码位置
              String currentChildModuleLocalPath = "../$childModule";
              if (parentModule == projectName) {
                currentChildModuleLocalPath = "$delegatePath/$childModule";
              }
              value = {PATH: currentChildModuleLocalPath};
              break;
            default:
              throw Exception("暂不支持$delegate模式");
          }
          // 记录真实的依赖
          realProjectModule[childModule] = delegate;
          // 写入更新后的YAML文件
          final yamlDocument = YamlEditor(pubText)..update([DEPENDENCIES, childModule], value);
          pubFile.writeAsStringSync(yamlDocument.toString());
          dPrint('$parentModule -> $childModule, ==>$value');
        }
        dPrint('---------');
      }
    }

    /// 切换依赖方式
    _switchModuleDelegate() {
      // 找出所有version.yaml注册的非第三方项目组件
      Map projectModule = Map.from(version)
        ..removeWhere(
            (key, value) => !(delegateGit[key] != null && delegateGit[key][THIRDPARTY] != true));
      if (projectModule.isEmpty) {
        return;
      }
      // 生成宿主工程根节点
      ModuleTreeNode projectRoot = _generateRootTreeNode(projectName, moduleConfig, delegateGit);
      // 根据不同的delegate分组
      Map<dynamic, List> groupedMap = groupByDelegate(projectModule);
      // 记录项目真实的依赖方式
      Map realModuleDependency = {};
      // 先遍历git组
      List? gitModuleList = groupedMap[GIT];
      gitModuleList?.forEach((element) {
        dPrint("*******************git*******************");
        // 更新
        _update(projectRoot, element, GIT, realModuleDependency);
      });
      // 再遍历path组
      List? pathModuleList = groupedMap[PATH];
      pathModuleList?.forEach((element) {
        dPrint("*******************path*******************");
        // 更新
        _update(projectRoot, element, PATH, realModuleDependency);
      });
      // 控制台输出真实配置文件依赖方式
      _printRealModuleDependency(realModuleDependency);
    }

    /**
     * 更新Module快照
     */
    _updateModuleSnapshot() {
      if (!snapshotModuleExists) {
        snapshotModuleFile.createSync(recursive: true);
      }
      moduleFile.copySync(PATH_MVM_SNAPSHOT_MODULE);
    }

    // 1. 匹配所有组件版本
    await _matchAllModuleVersion();
    // 2. 切换依赖方式
    _switchModuleDelegate();
    // 3. 更新Module快照
    _updateModuleSnapshot();
  }

  /// 生成项目根节点
  ModuleTreeNode _generateRootTreeNode(String projectName, Map moduleConfig, Map delegateGit) {
    /// 构建组件树结构
    Map<dynamic, Iterable<ModuleTreeNode>> transferMap = _buildModuleTree(moduleConfig, delegateGit);
    List<ModuleTreeNode> children = transferMap[projectName]?.toList() ?? [];
    // 构建宿主工程根节点
    ModuleTreeNode root = ModuleTreeNode(projectName, children);
    return root;
  }

  /// module.yaml转化为组件树结构
  Map<dynamic, Iterable<ModuleTreeNode>> _buildModuleTree(Map moduleConfig, Map delegateGit) {
    // 去皮，得到Map<parentModuleName, List<childModuleName>>
    Map<Object, List> modules =
        moduleConfig.map((key, value) => MapEntry(key, List.of(value[DEPENDENCIES])));
    // 移除非业务组件childModule
    modules.forEach((key, value) {
      value.removeWhere(
          (child) => !(delegateGit[child] != null && delegateGit[child][THIRDPARTY] != true));
    });

    /// 递归构建子module列表
    List<ModuleTreeNode> _generateSingleModuleChildren(final moduleName) {
      List children = modules[moduleName] ?? [];
      return children.map((name) => ModuleTreeNode(name, _generateSingleModuleChildren(name))).toList();
    }

    // 得到有向无环图
    Map<dynamic, Iterable<ModuleTreeNode>> transferMap = modules.map((key, value) =>
        MapEntry(key, value.map((e) => ModuleTreeNode(e.toString(), _generateSingleModuleChildren(e)))));
    return transferMap;
  }

  /// 根据不同的依赖方式分组
  Map<dynamic, List> groupByDelegate(Map inputMap) {
    Map<dynamic, List> groupedMap = {};

    inputMap.forEach((key, value) {
      groupedMap.putIfAbsent(value, () => []).add(key);
    });

    return groupedMap;
  }

  /// 输出真实配置文件依赖方式
  _printRealModuleDependency(Map realProjectModule) {
    print("=====================RealModuleDependency=========================");
    realProjectModule.forEach((key, value) {
      print("$key:$value");
    });
    print("---------------------Execution succeed----------------------------");
  }
}
