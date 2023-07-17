一个实用的Flutter命令行工具，支持Flutter组件管理、内置命令和自定义命令等

## 要求

最新的 `flutter_manager` 要求 Dart SDK `2.12.0` 或者更新。

## 下载

终端执行以下命令进行激活

```
$ dart pub global activate flutter_manager
```

在此处了解有关激活和使用命令行工具的更多信息[here](https://www.dartlang.org/tools/pub/cmd/pub-global).

## 更新

和下载一样，执行`dart pub global activate flutter_manager`即可

## 使用

```
manager <命令> [参数]
```

### 主要功能

```
manager mvm
```

`mvm`命令可以统一管理flutter组件库版本号以及一键切换本地path和远程git两种依赖方式。原理是工具通过读取`mvm`文件夹下的配置文件，构建一个有向无环图，然后对每个子结点到根节点的所有路径进行回溯。

**此库的最大优势在于：**

1. 使用成本低。由于是命令行工具，项目增删依赖库或更新库版本号时只需执行一次`manager mvm`即可

2. 改造成本低。原组件化方案几乎不用动，只需在`mvm`配置文件夹里配置项目结构及依赖即可，工具会自动识别并管理

3. 使用者不需要到子module手动增删依赖库或更新版本号，只需在统一的配置文件`mvm`内修改即可，工具会自动定位并在正确的module下更新。尤其是切换git和path依赖方式时，省去了重复繁琐的寻找过程

4. 各个module对三方库的依赖是相互独立的，因此统一的底层module是非必须的，真正做到`组件化`

5. 配置文件`version.yaml`对依赖库版本号的管理是整个项目共享的，即各子module使用统一版本的三方库，避免了版本冲突

6. 各组件的本地/远程分支可通过`delegate.yaml`配置文件的`ref`标签统一实时管理


配置文件在首次执行`manager mvm`时会自动生成模板，也可以手动创建。里面包含`module.yaml`，`version.yaml`和`delegate.yaml`，使用者将项目组件信息在这三个文件里面进行注册和更新。
每个文件的作用如下：

#### module.yaml

列出所有业务组件的dependencies依赖的库（包括宿主工程）

```yaml
yourModuleName:
  dependencies:
    - thirdPartyLibraryName
    - yourModuleName
```

#### version.yaml

配置所有依赖库的版本号（支持版本号，path和git三种方式）

```yaml
version:
  thirdPartyLibraryName1: versionCode
  thirdPartyLibraryName2: git
  yourModuleName1: git
  yourModuleName2: path
```

#### delegate.yaml

配置git和path依赖方式的实际地址

```yaml
# 所有组件的本地根路径
path: commonLocalRootPath
git:
  yourModuleName:
    git:
      url: ""
      #此组件的分支
      ref: ""
  thirdPartyLibraryName:
    git:
      url: ""
      ref: ""
```

**记住，配置文件发生变化时需要重新执行一遍`manager mvm`命令才会生效。**

当控制台出现`Execution succeed`日志关键字时表示任务执行成功，同时会打印项目组件之间真实的依赖关系，它可能和你在version.yaml配置的依赖方式不同，这是因为flutter要求某个组件到宿主工程的所有路径的真实依赖方式必须一致。不过你只需要关注version.yaml，日志仅提示有更好的依赖配置。

可以运行`example`样例体验。

### 其他功能

运行flutter命令，比如clean

```
manager clean
```

运行内置命令，比如删除一个文件

```
manager delete a.txt
```

运行自定义命令

```
manager custom ~/currentActivity.sh
```

```
manager custom flutter pub get
```

### 最后

每个命令都有一个缩写，通常是命令的第一个字符，可以运行 `manager help` 获得更多帮助。

```
Global options:
-h, --help    Print this usage information.

Available commands:
  clean    run flutter clean
  custom   run a custom command or its own script
  delete   run delete file, the default is pubspec.lock
  format   run flutter format .
  mvm      flutter module version manager
  pub      run flutter pub get (note: this is a parent command)
  pure     run delete,clean and pub get in order

Run "manager help <command>" for more information about a command.

```
