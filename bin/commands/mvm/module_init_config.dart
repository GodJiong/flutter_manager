import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';

/// FileName init_config
///
/// @Author wangjiong
/// @Date 2023/5/22
///
/// @Description: 初始化配置文件
class ModuleInitConfig {
  /// 是否首次初始化
  bool isFirstInitialization = false;

  /// 初始化module配置模板
  initModuleTemplate(File moduleFile) {
    final moduleTemplate = {
      "yourModuleName": {
        "dependencies": ["thirdPartyLibraryName", "yourModuleName"],
      }
    };
    _generateTemplate(moduleFile, moduleTemplate);
  }

  /// 初始化version配置模板
  initVersionTemplate(File versionFile) {
    final versionTemplate = {
      "version": {
        "thirdPartyLibraryName1": "versionCode",
        "thirdPartyLibraryName2": "git",
        "yourModuleName1": "git",
        "yourModuleName2": "path",
      },
    };
    _generateTemplate(versionFile, versionTemplate);
  }

  /// 初始化delegate配置模板
  initDelegateTemplate(File delegateFile) {
    final delegateTemplate = {
      "path": "commonLocalPath",
      "git": {
        "yourModuleName": {
          "git": {"url": "", "ref": ""}
        },
        "thirdPartyLibraryName": {
          "thirdParty": true,
          "git": {"url": "", "ref": ""}
        }
      }
    };
    _generateTemplate(delegateFile, delegateTemplate);
  }

  /// 生成模板
  bool _generateTemplate(File file, Map template) {
    bool isExists = file.existsSync();
    if (!isExists) {
      final yamlDocument = YamlEditor("")..update([], template);
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(yamlDocument.toString());
      print("${p.basenameWithoutExtension(file.path)}模板初始化完成");
      isFirstInitialization = true;
    }
    return isExists;
  }
}
