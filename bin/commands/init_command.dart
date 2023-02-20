import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import 'export_command.dart';

/// FileName init_command
///
/// @Author hxin
/// @Date 2022/10/31
///
/// @Description: InitCommand command

class InitCommand extends BaseCommand {

  factory InitCommand() => _instance;

  InitCommand._internal() {
    addSubcommand(DependCommand());
    //addSubcommand(RestoreCommand());
  }

  static late final InitCommand _instance = InitCommand._internal();

  @override
  String get description => "init depended";

  @override
  String get name => "init";

  @override
  List<String> get aliases => ["i"];
}

class DependCommand extends BaseCommand {
  factory DependCommand() => _instance;

  DependCommand._internal();

  static late final DependCommand _instance = DependCommand._internal();

  @override
  String get description => "init depended";

  @override
  String get name => "depend";

  @override
  List<String> get aliases => ["d"];

  @override
  Future<void> run([String? commands]) async {
    await init();
    return super.run(commands);
  }


  init() async {
    print("开始执行int()...");
    print("当前目录: " + dirname(Platform.script.path));
    File pubFile = File('pubspec.yaml');
    if (!pubFile.existsSync()) {
      print("no pubspec.yaml!!!");
      return;
    }

    File file_config_git = File('config_git.yaml');
    if (!file_config_git.existsSync()) {
      print("no config_git.yaml!!!");
      return;
    }

    File file_config_env = File('config_env.yaml');
    if (!file_config_env.existsSync()) {
      print("no config_env.yaml!!!");
      return;
    }

    // 读取pubspec.yaml文件转化内容为map
    String str_pubspec = pubFile.readAsStringSync();
    Map map_project_pubspec = Map.of(loadYaml(str_pubspec));
    Map map_project_dependencies = Map.of(map_project_pubspec?['dependencies']);
    Map map_project_dependencies_dev = Map.of(map_project_pubspec?['dev_dependencies']);
    //print("读取pubspec.yaml文件转化内容为map..." + map_project_pubspec.toString());

    // 读取config_git.yaml文件转化内容为map
    String str_config_git = file_config_git.readAsStringSync();
    // loadYaml()加载返回的是 unmodifiable Map，所以需要转一下
    Map? map_config_git = Map.of(loadYaml(str_config_git));
    Map? clone_config = map_config_git['clone_config'];
    String  str_clone_path = clone_config?["path"];
    Map? map_clone_git = map_config_git['clone_git'];
    print("===读取config_git.yaml文件");

    // 读取config_env.yaml文件转化内容为map
    String str_config_env = file_config_env.readAsStringSync();
    Map? map_config_env = Map.of(loadYaml(str_config_env));
    Map? map_config_dependencies_mode = Map.of(map_config_env?['dependencies']);
    Map? map_config_dependencies_dev;
    if(map_config_env?['dev_dependencies'] != null) {
      map_config_dependencies_dev = Map.of(map_config_env?['dev_dependencies']);
    }
    Map? map_config_version = map_config_env?['version'];
    Map? map_dependencies_all = map_config_env?['dependencies_all'];
    print("===读取config_env.yaml文件");
    //print("===读取map_config_env:" + map_config_env.toString());
    if(map_config_dependencies_mode == null) {
      print("===无依赖配置");
      return;
    }

    // 初始化:将config_env.yaml中的依赖配置copy到壳子工程中,默认依赖远端git
    for(MapEntry e in map_config_dependencies_mode.entries) {
      // dependencies
      if(map_project_dependencies != null) {
        map_project_dependencies[e.key] = map_clone_git?[e.key];
        map_project_pubspec?['dependencies'] = map_project_dependencies;
      }
      // dev_dependencies
      if(map_config_dependencies_dev != null) {
        map_project_dependencies_dev.addAll(map_config_dependencies_dev);
        map_project_pubspec?['dev_dependencies'] = map_project_dependencies_dev;
      }
      writeYaml(map_project_pubspec, pubFile);
    }
    print("===初始化:将config_env.yaml中dependencies依赖配置copy到壳子工程中,默认依赖远端git===end");

    // 源码/远端切换
    print("===源码/远端切换开始执行...");
    for (MapEntry e in map_config_dependencies_mode.entries) {
      if(e.value.toString() == 'r') {
        await modifyToRemote(map_config_dependencies_mode,map_dependencies_all, e, str_clone_path, map_clone_git);
        //print("======================================${e.key} ");
        // 修改config_env.yaml文件配置
        map_config_dependencies_mode[e?.key] = "r";
        // 修改壳工程配置
        map_project_dependencies[e.key] = map_clone_git?[e.key];
        map_project_pubspec?['dependencies'] = map_project_dependencies;
        // map_project_dependencies_dev[e.key] = map_clone_git?[e.key];
        // map_project_pubspec?['dev_dependencies'] = map_project_dependencies_dev;
      } else {
        // 开始递归向上查找依赖当前 module e 的 module 进行修改

        await recursionUpModify(map_project_pubspec,map_config_dependencies_mode,e,
            map_dependencies_all, str_clone_path, map_clone_git);
        print("===recursionModifyToLocal方法执行成功${e?.key?.toString()} 组件的配置 ");

        await modifyToLocal(e,map_dependencies_all,str_clone_path,map_clone_git);
        print("===modifyToLocal方法执行成功${e?.key?.toString()} 组件的配置 ");
        // 刷新e在config中的远程开关 and 壳子工程中的依赖模式
        map_config_dependencies_mode[e?.key] = "";
        String d = str_clone_path + '/' + e.key;
        map_project_dependencies[e.key] = {"path": d};
        map_project_pubspec?['dependencies'] = map_project_dependencies;
        print("===修改map_config_dependencies_mode and map_project_dependencies中${e?.key?.toString()} 组件的配置 ");

        // recursionModifyToLocal(map_project_pubspec,map_config_dependencies_mode,e,
        //     map_dependencies_all, str_clone_path, map_clone_git).catchError((e) {
        //   print("===recursionModifyToLocal方法执行失败${e?.key?.toString()} 组件的配置 ");
        //   print(e);
        // }).then((value) {
        //   print("===recursionModifyToLocal方法执行成功${e?.key?.toString()} 组件的配置 ");
        //
        //   modifyToLocal(e,map_dependencies_all,str_clone_path,map_clone_git).then((value) {
        //     print("===modifyToLocal方法执行成功${e?.key?.toString()} 组件的配置 ");
        //     // 刷新e在config中的远程开关 and 壳子工程中的依赖模式
        //     map_config_dependencies_mode[e?.key] = "";
        //     String d = str_clone_path + '/' + e.key;
        //     map_project_dependencies[e.key] = {"path": d};
        //     map_project_pubspec?['dependencies'] = map_project_dependencies;
        //     print("===修改map_config_dependencies_mode and map_project_dependencies中${e?.key?.toString()} 组件的配置 ");
        //   });
        //
        // }).whenComplete(() {
        //   print("===recursionModifyToLocal方法执行完成${e?.key?.toString()} 组件的配置 ");
        // });
      }
    }

    // 将递归查找的组件 map_config_dependencies_mode 源码依赖写入yaml
    // map_config_env['dependencies_mode'] = map_config_dependencies_mode;
    // writeYaml(map_config_env, file_config_env);
    //print("===map_config_dependencies_mode写入config_env.yaml文件完成");

    // 刷新壳工程pubsepec.yaml文件dependencies and dev_dependencies
    writeYaml(map_project_pubspec, pubFile);
    print("===dependencies and dev_dependencies写入壳工程pubsepec.yaml文件完成");
    //print("===Isolate.current.debugName：${Isolate.current.debugName}");
  }

  modifyToRemote(Map? map_config_dependencies_mode,Map? map_dependencies_all,MapEntry e,String str_clone_path,Map? map_clone_git) async {

    print("===modifyToRemote()开始执行当前组件："+e.key);

    if(map_dependencies_all == null) {
      print("===map_dependencies_all is null...");
      return;
    }

    // 刷新依赖e的module
    for(var en in map_dependencies_all.entries) {
      if(en.key == e?.key) {
        continue;
      }

      Map? dependencies = en.value ['dependencies'];
      Map? dependencies_dev = en.value ['dev_dependencies'];

      //print("===dependencies_dev:" + dependencies_dev.toString());

      // 找到依赖e的module,刷新这个module
      if(dependencies != null && dependencies.containsKey(e?.key)) {
        print("===modifyToRemote()开始执行===组件：${e.key} 被组件${en.key}依赖");
        final dir = str_clone_path + '/' + en.key;
        final pubFile = File(p.join(dir, 'pubspec.yaml'));
        if (!pubFile.existsSync()) {
          // 本地无源码
          continue;
        }
        print("===本地有 ${en.key} 组件源码 ");
        // 刷新 yaml dependencies 为远端
        String str_pubspec = pubFile.readAsStringSync();
        //print("===pubFile.path:" + pubFile.path);
        print("===pubFile.path:" + str_pubspec.length.toString());
        if(str_pubspec.isEmpty) {
          print("===str_pubspec.isEmpty");
        }
        Map map_yaml = loadYaml(str_pubspec);
        //print("===loadYaml(str_pubspec) == null:" + "${loadYaml(value) == null}");
        Map map_pubspec_new = Map.of(map_yaml);
        if(map_pubspec_new['dependencies'] != null) {
          Map map_pubspec_dependencies_new = Map.of(map_pubspec_new['dependencies']);
          map_pubspec_dependencies_new[e.key] = map_clone_git?[e.key];
          map_pubspec_new['dependencies'] = map_pubspec_dependencies_new;
        }
        if(map_pubspec_new['dev_dependencies'] != null) {
          Map map_pubspec_dependencies_dev_new = Map.of(map_pubspec_new['dev_dependencies']);
          if(dependencies_dev != null && dependencies_dev.containsKey(e.key)) {
            map_pubspec_dependencies_dev_new[e.key] = map_clone_git?[e.key];
            map_pubspec_new['dev_dependencies'] = map_pubspec_dependencies_dev_new;
          }
        }
        writeYaml(map_pubspec_new, pubFile);
        print("===写入子module完成");
      } else {
        print("===modifyToRemote()==结束===组件：${e.key} 没有被组件${en.key}依赖");
      }
    }
    print("===modifyToRemote()===结束===当前组件：${e.key}");
  }
  modifyToLocal(MapEntry e,Map? map_dependencies_all,String str_clone_path,Map? map_clone_git) async {
    // 开始 module e clone,检查源码工程是否存在
    print("===modifyToLocal===start===当前组件：${e.key}");
    final dir = str_clone_path + '/' + e.key;
    final pubFile = File(p.join(dir, 'pubspec.yaml'));
    if(!pubFile.existsSync()) {
      // git 地址
      final url = map_clone_git?[e.key]["git"]?["url"];
      // git 分支
      final ref = map_clone_git?[e.key]["git"]?["ref"] ?? "master";
      if (url == null) {
        return;
      }
      print("===modifyToLocal===clone开始："+url);
      await clone(url, dir, ref);
      print("===modifyToLocal===clone结束："+url);
      //再次验证是否存在
      final pubFile1 = File(p.join(dir, 'pubspec.yaml'));
      if (!pubFile1.existsSync()) {
        print("===modifyToLocal===clone失败本地文件不存在："+url);
        return;
      }
      if(map_dependencies_all == null) {
        print("===map_dependencies_all is null...");
        return;
      }
      Map dependencies_new = Map.of(map_dependencies_all[e.key]['dependencies']);
      for(var entry in dependencies_new.entries) {
        if(entry.value == 'git') {
          dependencies_new[entry.key] = map_clone_git?[entry.key];
        }
      }
      String str_pub_spec = pubFile.readAsStringSync();
      Map map_pub_spec = Map.of(loadYaml(str_pub_spec));
      Map dependencies = Map.of(map_pub_spec['dependencies']);
      dependencies.addAll(dependencies_new);

      // 更新dependencies节点
      map_pub_spec["dependencies"] = dependencies;
      // 重新复写pubspec.yaml文件
      writeYaml(map_pub_spec, pubFile);
    }
    print("===modifyToLocal===end===当前组件：${e.key}");
  }

  /**
   * 1、递归找出需要clone的组件clone
   * 2、将config_env.yaml中dependencies_all部分的配置copy到相应的module中的yaml中
   */
  recursionUpModify(Map map_project_pubspec,Map map_config_dependencies_mode,
      MapEntry? e,Map? map_dependencies_all,String str_clone_path,Map? map_clone_git) async {

    print("===进入recursionUpModify方法，当前module是${e?.key?.toString()}");
    if (e == null) {
      print("===退出recursionUpModify方法");
      return Future.value();
    }

    MapEntry? entry;
    Map? map_project_dependencies = map_project_pubspec?['dependencies'];
    Map? map_project_dependencies_dev = map_project_pubspec?['dev_dependencies'];

    if(map_dependencies_all == null) {
      print("===map_dependencies_all无配置,请检查!!!");
      return Future.value();;
    }

    for(var en in map_dependencies_all.entries) {

      if(en.key == e?.key) {
        continue;
      }

      Map? dependencies = en.value ['dependencies'];
      Map? dependencies_dev = en.value ['dev_dependencies'];
      if(dependencies != null && dependencies.containsKey(e?.key)) {
        entry = en;
        //当前module e有被其他module依赖,需要先clone这些module
        print("===当前module "+ e?.key + "被module" + en?.key + "依赖");
        final eDir = '../' + e.key;
        final mDir = str_clone_path + '/' + en.key;
        final pubFile = File(p.join(mDir, 'pubspec.yaml'));
        if(!pubFile.existsSync()) {
          // git 地址
          final url = map_clone_git?[en.key]["git"]?["url"];
          // git 分支
          final ref = map_clone_git?[en.key]["git"]?["ref"] ?? "master";
          if (url == null) {
            continue;
          }
          await clone(url, mDir, ref);
          if(!pubFile.existsSync()) {
            print("===clone失败===mDir: " + mDir);
            continue;
          }
          print("===clone成功===mDir: " + mDir);
        }
        // e 本地存在
        // 开始copy配置信息到module en
        print("===recursionUpModify===开始copy配置信息到各module...");
        String str_pubspec = pubFile.readAsStringSync();
        Map map_pubspec_old = Map.of(loadYaml(str_pubspec));
        Map map_pubspec_dependencies_old = Map.of(map_pubspec_old['dependencies']);
        Map map_pubspec_dependencies_dev_old = Map.of(map_pubspec_old['dev_dependencies']);

        // 将module en中module e的依赖方式改为源码依赖
        map_pubspec_dependencies_old.addAll(dependencies);
        map_pubspec_dependencies_old[e?.key] = {"path": eDir};

        if(dependencies_dev != null) {
          map_pubspec_dependencies_dev_old.addAll(dependencies_dev);
        }
        if (map_pubspec_dependencies_dev_old.containsKey(e?.key)) {
          map_pubspec_dependencies_dev_old[e?.key] = {"path": eDir};
        }

        //检查全量依赖项将需要修改的进行修正，以map_config_dependencies_mode为准
        for(var entry in map_pubspec_dependencies_old.entries) {
          if(entry.value == 'git') {
            if(!map_config_dependencies_mode.containsKey(entry.key)) {
              map_pubspec_dependencies_old[entry.key] = map_clone_git?[entry.key];
              continue;
            }

            if(map_config_dependencies_mode[entry?.key] != '') {
              map_pubspec_dependencies_old[entry.key] = map_clone_git?[entry.key];
              continue;
            } else {
              map_pubspec_dependencies_old[entry?.key] = {"path": eDir};
            }
          }
        }

        // 更新dependencies内容并写到pubspec.yaml in module en
        map_pubspec_old["dependencies"] = map_pubspec_dependencies_old;
        map_pubspec_old['dev_dependencies'] = map_pubspec_dependencies_dev_old;
        // 重新复写pubspec.yaml文件
        writeYaml(map_pubspec_old, pubFile);

        // 刷新e的dependencies_mode值为源码模式
        map_config_dependencies_mode[e?.key] = "";
        // 刷新en在壳子工程依赖模式
        map_project_dependencies?[en.key] = {"path": mDir};
        map_project_pubspec?['dependencies'] = map_project_dependencies;
        print("===recursionUpModify===module"+en.key+"刷新配置完成");


      } else {
        print("===当前module "+ e?.key + "没有被module" + en?.key + "依赖");
      }
    }

    // 继续向上查找
    print("===调用recursionUpModify继续向上查找依赖${entry?.key?.toString()}的组件");
    recursionUpModify(map_project_pubspec,map_config_dependencies_mode, entry,
        map_dependencies_all, str_clone_path, map_clone_git);
    print("===退出recursionUpModify方法");
    return;
  }

  // git clone
  clone(String url, String path, String ref) async {
    // git 命令
    final git = " git clone $url $path -b $ref";
    await CustomCommand().run(git);
  }

  // 重新复写pubspec.yaml文件
  void writeYaml(Map yaml, File pubFile, {bool flush = true}) {
    var yamlWriter = YAMLWriter();
    // 转化为yaml格式字符串
    var yamlDoc = yamlWriter.write(yaml);
    pubFile.writeAsStringSync(yamlDoc,flush: flush);
  }

}
